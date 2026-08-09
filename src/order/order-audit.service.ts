import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';

@Injectable()
export class OrderAuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(params: {
    employeeId?: string;
    action: string;
    referenceId?: string;
    description?: string;
  }): Promise<void> {
    await this.prisma.auditLog.create({
      data: {
        employeeId: params.employeeId,
        module: 'order',
        action: params.action,
        referenceId: params.referenceId,
        description: params.description,
      },
    });
  }
}
