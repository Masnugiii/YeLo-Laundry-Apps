import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';

export interface HealthCheckResult {
  status: 'ok' | 'error';
  database: 'connected' | 'disconnected';
  timestamp: string;
}

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  async check(): Promise<HealthCheckResult> {
    const databaseHealthy = await this.prisma.isHealthy();

    return {
      status: databaseHealthy ? 'ok' : 'error',
      database: databaseHealthy ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
    };
  }
}
