import {
  INestApplication,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

export type DatabaseUrlDiagnostics = {
  present: boolean;
  parseable: boolean;
  protocol: string | null;
  username: string | null;
  hostname: string | null;
  port: string | null;
  database: string | null;
  hasPgbouncer: boolean;
  hasSslmodeRequire: boolean;
  looksLikePooler: boolean;
  passwordPresent: boolean;
};

export type PrismaConnectionFailureKind =
  | 'auth_failed'
  | 'unreachable'
  | 'timeout'
  | 'pooler_prepared_statement'
  | 'ssl'
  | 'malformed_url'
  | 'unknown';

/**
 * Append a query param without re-serializing userinfo.
 * Using `new URL(...).toString()` can corrupt passwords that contain
 * reserved characters and break production auth against Postgres.
 */
export function appendQueryParam(
  raw: string,
  key: string,
  value: string,
): string {
  if (hasQueryParam(raw, key)) {
    return raw;
  }
  const separator = raw.includes('?') ? '&' : '?';
  return `${raw}${separator}${key}=${encodeURIComponent(value)}`;
}

export function hasQueryParam(raw: string, key: string): boolean {
  const queryIndex = raw.indexOf('?');
  if (queryIndex < 0) {
    return false;
  }
  const query = raw.slice(queryIndex + 1);
  return query.split('&').some((part) => {
    const [name] = part.split('=', 1);
    return decodeURIComponent(name) === key;
  });
}

/**
 * Adapt DATABASE_URL for Prisma without mutating Railway Variables and without
 * rewriting username/password via URL serialization.
 */
export function resolvePrismaDatabaseUrl(
  raw: string | undefined = process.env.DATABASE_URL,
): string | undefined {
  if (!raw?.trim()) {
    return raw;
  }

  const diagnostics = inspectDatabaseUrl(raw);
  if (!diagnostics.parseable || !diagnostics.hostname) {
    return raw;
  }

  let resolved = raw.trim();
  const host = diagnostics.hostname.toLowerCase();
  const isPooler =
    diagnostics.looksLikePooler ||
    host.includes('pooler.') ||
    diagnostics.port === '6543';

  if (isPooler && !diagnostics.hasPgbouncer) {
    resolved = appendQueryParam(resolved, 'pgbouncer', 'true');
  }

  if (host.includes('supabase') && !hasQueryParam(resolved, 'sslmode')) {
    resolved = appendQueryParam(resolved, 'sslmode', 'require');
  }

  return resolved;
}

export function inspectDatabaseUrl(
  raw: string | undefined = process.env.DATABASE_URL,
): DatabaseUrlDiagnostics {
  if (!raw?.trim()) {
    return {
      present: false,
      parseable: false,
      protocol: null,
      username: null,
      hostname: null,
      port: null,
      database: null,
      hasPgbouncer: false,
      hasSslmodeRequire: false,
      looksLikePooler: false,
      passwordPresent: false,
    };
  }

  try {
    // Parse without reconstructing the secret-bearing URL.
    const match = raw
      .trim()
      .match(
        /^(?<protocol>postgres(?:ql)?):\/\/(?:(?<username>[^:/?#\[\]]+)(?::(?<password>[^@]*))?@)?(?<hostname>\[[^\]]+\]|[^:/?#]+)(?::(?<port>\d+))?(?:\/(?<database>[^?]*))?(?:\?(?<query>.*))?$/i,
      );

    if (!match?.groups) {
      return {
        present: true,
        parseable: false,
        protocol: null,
        username: null,
        hostname: null,
        port: null,
        database: null,
        hasPgbouncer: hasQueryParam(raw, 'pgbouncer'),
        hasSslmodeRequire:
          hasQueryParam(raw, 'sslmode') &&
          /(?:^|[?&])sslmode=require(?:&|$)/i.test(raw),
        looksLikePooler: false,
        passwordPresent: false,
      };
    }

    const protocol = match.groups.protocol ?? null;
    const username = match.groups.username
      ? decodeURIComponent(match.groups.username)
      : null;
    const hostname = match.groups.hostname ?? null;
    const port = match.groups.port ?? (hostname ? '5432' : null);
    const database = match.groups.database
      ? decodeURIComponent(match.groups.database)
      : null;
    const passwordPresent = typeof match.groups.password === 'string';
    const hasPgbouncer =
      hasQueryParam(raw, 'pgbouncer') &&
      /(?:^|[?&])pgbouncer=true(?:&|$)/i.test(raw);
    const hasSslmodeRequire =
      hasQueryParam(raw, 'sslmode') &&
      /(?:^|[?&])sslmode=require(?:&|$)/i.test(raw);
    const looksLikePooler = Boolean(
      hostname &&
        (hostname.toLowerCase().includes('pooler.') ||
          hostname.toLowerCase().includes('-pooler.') ||
          port === '6543'),
    );

    return {
      present: true,
      parseable: true,
      protocol,
      username,
      hostname,
      port,
      database,
      hasPgbouncer,
      hasSslmodeRequire,
      looksLikePooler,
      passwordPresent,
    };
  } catch {
    return {
      present: true,
      parseable: false,
      protocol: null,
      username: null,
      hostname: null,
      port: null,
      database: null,
      hasPgbouncer: false,
      hasSslmodeRequire: false,
      looksLikePooler: false,
      passwordPresent: false,
    };
  }
}

export function formatDatabaseUrlDiagnostics(
  diagnostics: DatabaseUrlDiagnostics = inspectDatabaseUrl(),
): string {
  return [
    `present=${diagnostics.present}`,
    `parseable=${diagnostics.parseable}`,
    `protocol=${diagnostics.protocol ?? '-'}`,
    `username=${diagnostics.username ?? '-'}`,
    `hostname=${diagnostics.hostname ?? '-'}`,
    `port=${diagnostics.port ?? '-'}`,
    `database=${diagnostics.database ?? '-'}`,
    `passwordPresent=${diagnostics.passwordPresent}`,
    `pgbouncer=${diagnostics.hasPgbouncer}`,
    `sslmode_require=${diagnostics.hasSslmodeRequire}`,
    `looksLikePooler=${diagnostics.looksLikePooler}`,
  ].join(' ');
}

export function databaseHostFingerprint(
  raw: string | undefined = process.env.DATABASE_URL,
): string {
  const diagnostics = inspectDatabaseUrl(raw);
  if (!diagnostics.parseable || !diagnostics.hostname) {
    return diagnostics.present ? '(unparseable)' : '(missing)';
  }
  return `${diagnostics.hostname}:${diagnostics.port ?? '5432'}/${diagnostics.database || 'db'}`;
}

export function classifyPrismaConnectionError(
  error: unknown,
): PrismaConnectionFailureKind {
  const message = (
    error instanceof Error ? error.message : String(error)
  ).toLowerCase();

  if (
    message.includes('authentication failed') ||
    message.includes('credentials') ||
    message.includes('password authentication failed') ||
    message.includes('28p01')
  ) {
    return 'auth_failed';
  }
  if (
    message.includes('ssl') ||
    message.includes('certificate') ||
    message.includes('tls')
  ) {
    return 'ssl';
  }
  if (
    message.includes('prepared statement') ||
    message.includes('pgbouncer')
  ) {
    return 'pooler_prepared_statement';
  }
  if (
    message.includes('timed out') ||
    message.includes('timeout') ||
    message.includes('p1008') ||
    message.includes('p2024')
  ) {
    return 'timeout';
  }
  if (
    message.includes("can't reach database") ||
    message.includes('p1001') ||
    message.includes('enotfound') ||
    message.includes('econnrefused') ||
    message.includes('server has closed the connection') ||
    message.includes('p1017')
  ) {
    return 'unreachable';
  }
  if (message.includes('invalid connection string') || message.includes('malformed')) {
    return 'malformed_url';
  }
  return 'unknown';
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
      message.includes('timeout') ||
      message.includes('authentication failed') ||
      message.includes('credentials') ||
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
    const diagnostics = inspectDatabaseUrl(process.env.DATABASE_URL);
    this.logger.log(
      `Prisma DATABASE_URL diagnostics: ${formatDatabaseUrlDiagnostics(diagnostics)}`,
    );
    this.logger.log(
      `Prisma resolved URL flags: ${formatDatabaseUrlDiagnostics(
        inspectDatabaseUrl(resolvePrismaDatabaseUrl(process.env.DATABASE_URL)),
      )}`,
    );

    try {
      await this.connectWithRetry();
      this.logger.log(
        `Prisma connected (${databaseHostFingerprint()})`,
      );
    } catch (error: unknown) {
      const kind = classifyPrismaConnectionError(error);
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Prisma initial connect failed kind=${kind} host=${databaseHostFingerprint()}: ${message}`,
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

  async ensureConnected(): Promise<void> {
    try {
      await this.$queryRaw`SELECT 1`;
      return;
    } catch (error: unknown) {
      if (!isPrismaConnectionError(error)) {
        throw error;
      }
      const kind = classifyPrismaConnectionError(error);
      this.logger.warn(
        `Prisma connectivity check failed kind=${kind}; reconnecting (${databaseHostFingerprint()})`,
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
          const kind = classifyPrismaConnectionError(error);
          const message =
            error instanceof Error ? error.message : String(error);
          this.logger.warn(
            `Prisma $connect attempt ${attempt}/${maxAttempts} kind=${kind}: ${message}`,
          );
          // Auth failures will not recover by retrying the same credentials.
          if (kind === 'auth_failed' || kind === 'malformed_url') {
            break;
          }
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
