import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';

export interface HealthCheckResult {
  status: 'ok' | 'error';
  database: 'connected' | 'disconnected';
  timestamp: string;
  databaseConnection?: {
    configured: {
      present: boolean;
      parseable: boolean;
      protocol: string | null;
      username: string | null;
      hostname: string | null;
      port: string | null;
      database: string | null;
      passwordPresent: boolean;
      pgbouncer: boolean;
      sslmodeRequire: boolean;
      looksLikePooler: boolean;
    };
    resolved: {
      present: boolean;
      parseable: boolean;
      protocol: string | null;
      username: string | null;
      hostname: string | null;
      port: string | null;
      database: string | null;
      passwordPresent: boolean;
      pgbouncer: boolean;
      sslmodeRequire: boolean;
      looksLikePooler: boolean;
    };
    lastErrorKind: string | null;
    lastErrorMessage: string | null;
  };
}

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  async check(): Promise<HealthCheckResult> {
    const databaseHealthy = await this.prisma.isHealthy();
    const databaseConnection = this.prisma.getConnectionDiagnostics();

    return {
      status: databaseHealthy ? 'ok' : 'error',
      database: databaseHealthy ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
      databaseConnection,
    };
  }
}
