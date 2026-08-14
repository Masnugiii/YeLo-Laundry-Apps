import {
  INestApplication,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

/**
 * Adapt DATABASE_URL for Prisma without mutating Railway env.
 * Supabase (and similar) transaction poolers require pgbouncer=true or
 * prepared-statement queries fail after connect and surface as opaque 500s.
 */
export function resolvePrismaDatabaseUrl(
  raw: string | undefined = process.env.DATABASE_URL,
): string | undefined {
  if (!raw?.trim()) {
    return raw;
  }

  try {
    const normalized = raw.replace(/^postgresql:/i, 'postgres:');
    const url = new URL(normalized);
    const host = url.hostname.toLowerCase();
    const isPooler =
      host.includes('pooler.') ||
      host.includes('-pooler.') ||
      url.port === '6543';

    if (isPooler && url.searchParams.get('pgbouncer') !== 'true') {
      url.searchParams.set('pgbouncer', 'true');
    }

    if (!url.searchParams.has('sslmode') && host.includes('supabase')) {
      url.searchParams.set('sslmode', 'require');
    }

    return url.toString().replace(/^postgres:/, 'postgresql:');
  } catch {
    return raw;
  }
}

export function databaseHostFingerprint(
  raw: string | undefined = process.env.DATABASE_URL,
): string {
  if (!raw) {
    return '(missing)';
  }
  try {
    const url = new URL(raw.replace(/^postgresql:/i, 'postgres:'));
    return `${url.hostname}:${url.port || '5432'}/${(url.pathname || '/').replace(/^\//, '').split('?')[0] || 'db'}`;
  } catch {
    return '(unparseable)';
  }
}

export function isPrismaConnectionError(error: unknown): boolean {
  if (error instanceof Prisma.PrismaClientInitializationError) {
    return true;
  }
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    return ['P1001', 'P1002', 'P1008', 'P1017', 'P2024'].includes(error.code);
  }
  if (error instanceof Prisma.PrismaClientRustPanicError) {
    return true;
  }
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    return (
      message.includes("can't reach database") ||
      message.includes('connection') ||
      message.includes('timed out') ||
      message.includes('server has closed the connection') ||
      message.includes('prepared statement')
    );
  }
  return false;
}

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);
  private connectPromise: Promise<void> | null = null;

  constructor() {
    const url = resolvePrismaDatabaseUrl(process.env.DATABASE_URL);
    super(
      url
        ? {
            datasources: {
              db: { url },
            },
          }
        : undefined,
    );
  }

  async onModuleInit(): Promise<void> {
    const host = databaseHostFingerprint();
    this.logger.log(`Prisma connecting (host=${host})`);
    try {
      await this.connectWithRetry();
      this.logger.log(`Prisma connected (host=${host})`);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      // Do not block HTTP listen forever; login/health will retry via ensureConnected.
      this.logger.error(
        `Prisma initial connect failed (host=${host}): ${message}`,
      );
    }
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  enableShutdownHooks(app: INestApplication): void {
    process.on('beforeExit', async () => {
      await app.close();
    });
  }

  async isHealthy(): Promise<boolean> {
    try {
      await this.ensureConnected();
      await this.$queryRaw`SELECT 1`;
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Ensure a live connection before auth/critical queries.
   * Reconnects after idle pooler drops without logging secrets.
   */
  async ensureConnected(): Promise<void> {
    try {
      await this.$queryRaw`SELECT 1`;
      return;
    } catch (error: unknown) {
      if (!isPrismaConnectionError(error)) {
        throw error;
      }
      this.logger.warn(
        `Prisma connectivity check failed; reconnecting (host=${databaseHostFingerprint()})`,
      );
      await this.connectWithRetry();
    }
  }

  private async connectWithRetry(maxAttempts = 3): Promise<void> {
    if (this.connectPromise) {
      return this.connectPromise;
    }

    this.connectPromise = (async () => {
      let lastError: unknown;
      for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
        try {
          await this.$connect();
          return;
        } catch (error: unknown) {
          lastError = error;
          const message =
            error instanceof Error ? error.message : String(error);
          this.logger.warn(
            `Prisma $connect attempt ${attempt}/${maxAttempts} failed: ${message}`,
          );
          await new Promise((resolve) => setTimeout(resolve, attempt * 500));
        }
      }
      throw lastError instanceof Error
        ? lastError
        : new Error(String(lastError));
    })();

    try {
      await this.connectPromise;
    } finally {
      this.connectPromise = null;
    }
  }
}
