import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';

export interface HealthCheckResult {
  status: 'ok' | 'error';
  database: 'connected' | 'disconnected';
  timestamp: string;
  authSchema?: {
    ready: boolean;
    missing: string[];
  };
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
    let authSchema: HealthCheckResult['authSchema'];

    if (databaseHealthy) {
      try {
        const rows = await this.prisma.$queryRaw<Array<{ table_name: string }>>`
          SELECT table_name
          FROM information_schema.tables
          WHERE table_schema = 'public'
            AND table_name = ANY(ARRAY[
              'employees',
              'roles',
              'employee_roles',
              'permissions',
              'role_permissions'
            ])
        `;
        const present = new Set(rows.map((row) => row.table_name));
        const required = [
          'employees',
          'roles',
          'employee_roles',
          'permissions',
          'role_permissions',
        ];
        const missing = required.filter((name) => !present.has(name));
        authSchema = {
          ready: missing.length === 0,
          missing,
        };
      } catch {
        authSchema = {
          ready: false,
          missing: ['(schema_probe_failed)'],
        };
      }
    }

    return {
      status: databaseHealthy ? 'ok' : 'error',
      database: databaseHealthy ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
      databaseConnection,
      authSchema,
    };
  }
}
