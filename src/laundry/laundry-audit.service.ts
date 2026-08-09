import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';

@Injectable()
export class LaundryAuditService {
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
        module: 'laundry',
        action: params.action,
        referenceId: params.referenceId,
        description: params.description,
      },
    });
  }
}
