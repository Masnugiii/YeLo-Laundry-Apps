import { Injectable } from '@nestjs/common';
import { PayrollRecordStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { PayrollQueryDto } from './payroll.dto';
import { PayrollRecordWithRelations } from './payroll.mapper';

const payrollInclude = {
  employee: {
    select: { id: true, employeeCode: true, fullName: true, position: true },
  },
  bonuses: true,
  deductions: true,
  approvalHistory: {
    orderBy: { createdAt: 'asc' as const },
    include: {
      actor: { select: { id: true, fullName: true, employeeCode: true } },
    },
  },
  payments: {
    orderBy: { paidAt: 'desc' as const },
    include: {
      paidBy: { select: { id: true, fullName: true, employeeCode: true } },
    },
  },
};

@Injectable()
export class PayrollRepository {
  constructor(private readonly prisma: PrismaService) {}

  findMany(query: PayrollQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 25;
    const where = this.buildWhere(query);

    return this.prisma.$transaction([
      this.prisma.payrollRecord.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ periodEnd: 'desc' }, { createdAt: 'desc' }],
        include: payrollInclude,
      }),
      this.prisma.payrollRecord.count({ where }),
    ]);
  }

  findById(id: string): Promise<PayrollRecordWithRelations | null> {
    return this.prisma.payrollRecord.findFirst({
      where: { id, deletedAt: null },
      include: payrollInclude,
    });
  }

  async nextPayrollNumber(periodEnd: Date): Promise<string> {
    const prefix = `PAY-${periodEnd.toISOString().slice(0, 10).replace(/-/g, '')}`;
    const count = await this.prisma.payrollRecord.count({
      where: { payrollNumber: { startsWith: prefix } },
    });
    return `${prefix}-${String(count + 1).padStart(4, '0')}`;
  }

  createRecord(data: Prisma.PayrollRecordCreateInput) {
    return this.prisma.payrollRecord.create({
      data,
      include: payrollInclude,
    });
  }

  updateRecord(id: string, data: Prisma.PayrollRecordUpdateInput) {
    return this.prisma.payrollRecord.update({
      where: { id },
      data,
      include: payrollInclude,
    });
  }

  replaceBonuses(payrollRecordId: string, bonuses: Array<{ type: string; amount: number; notes?: string }>) {
    return this.prisma.$transaction([
      this.prisma.payrollBonus.deleteMany({ where: { payrollRecordId } }),
      ...bonuses.map((bonus) =>
        this.prisma.payrollBonus.create({
          data: {
            payrollRecordId,
            type: bonus.type as never,
            amount: bonus.amount,
            notes: bonus.notes,
          },
        }),
      ),
    ]);
  }

  addApprovalEvent(input: {
    payrollRecordId: string;
    status: PayrollRecordStatus;
    actorEmployeeId: string;
    notes?: string;
  }) {
    return this.prisma.payrollApprovalEvent.create({ data: input });
  }

  addPayment(input: {
    payrollRecordId: string;
    method: 'CASH' | 'TRANSFER' | 'WALLET';
    amount: number;
    referenceNumber?: string;
    notes?: string;
    paidAt: Date;
    paidByEmployeeId: string;
  }) {
    return this.prisma.payrollPayment.create({ data: input });
  }

  aggregateDashboard(periodStart?: Date, periodEnd?: Date) {
    const where: Prisma.PayrollRecordWhereInput = { deletedAt: null };
    if (periodStart && periodEnd) {
      where.periodStart = periodStart;
      where.periodEnd = periodEnd;
    }

    return this.prisma.payrollRecord.groupBy({
      by: ['status'],
      where,
      _count: { _all: true },
      _sum: {
        netSalary: true,
        totalBonus: true,
        totalDeduction: true,
      },
    });
  }

  private buildWhere(query: PayrollQueryDto): Prisma.PayrollRecordWhereInput {
    const where: Prisma.PayrollRecordWhereInput = { deletedAt: null };
    if (query.employeeId) where.employeeId = query.employeeId;
    if (query.role) where.role = query.role;
    if (query.status) where.status = query.status;
    if (query.periodStart) where.periodStart = query.periodStart;
    if (query.periodEnd) where.periodEnd = query.periodEnd;
    return where;
  }
}
