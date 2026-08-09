import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  CashflowType,
  ReferenceType,
} from '@prisma/client';
import { randomUUID } from 'crypto';
import { PrismaService } from '../database/prisma/prisma.service';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { FinanceAuditService } from './finance-audit.service';
import { FinanceSettingsRepository } from './finance-settings.repository';
import {
  AdjustIncomeDto,
  CashTransactionDto,
  CloseShiftDto,
  CreateVoucherDto,
  DailyClosingQueryDto,
  OpenShiftDto,
  ValidateVoucherDto,
} from './dto/cash.dto';
import {
  CashShiftRecord,
  DailyClosingRecord,
} from './utils/cash-shift-meta.util';
import {
  getVoucherRemainingUsage,
  isVoucherExpired,
  VoucherRecord,
} from './utils/voucher-meta.util';
import { formatFinanceReferenceDate } from './utils/finance-reference.util';

@Injectable()
export class CashService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly financeSettings: FinanceSettingsRepository,
    private readonly auditService: FinanceAuditService,
  ) {}

  async getActiveShift(): Promise<ApiSuccessResponse<CashShiftRecord | null>> {
    const shift = await this.financeSettings.getActiveShift();

    return {
      success: true,
      message: shift
        ? 'Active cash shift retrieved successfully'
        : 'No active cash shift',
      data: shift,
    };
  }

  async openShift(
    dto: OpenShiftDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    const active = await this.financeSettings.getActiveShift();

    if (active?.status === 'OPEN') {
      throw new BadRequestException('A cash shift is already open');
    }

    const shift: CashShiftRecord = {
      id: randomUUID(),
      status: 'OPEN',
      openedAt: new Date().toISOString(),
      openedByEmployeeId: employeeId,
      openingCash: dto.openingCash,
      totalCashIn: 0,
      totalCashOut: 0,
      notes: dto.notes,
    };

    await this.financeSettings.saveActiveShift(shift);

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'cash_shift_opened',
      referenceId: shift.id,
      description: `Cash shift opened with float ${dto.openingCash}`,
    });

    return {
      success: true,
      message: 'Cash shift opened successfully',
      data: shift,
    };
  }

  async closeShift(
    dto: CloseShiftDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    const active = await this.financeSettings.getActiveShift();

    if (!active || active.status !== 'OPEN') {
      throw new NotFoundException('No active cash shift found');
    }

    const expectedCash =
      active.openingCash + active.totalCashIn - active.totalCashOut;
    const difference = Number((dto.actualCash - expectedCash).toFixed(2));

    const closedShift: CashShiftRecord = {
      ...active,
      status: 'CLOSED',
      closedAt: new Date().toISOString(),
      closedByEmployeeId: employeeId,
      expectedCash,
      actualCash: dto.actualCash,
      difference,
      notes: dto.notes ?? active.notes,
    };

    await this.financeSettings.saveShiftHistory(closedShift);
    await this.financeSettings.clearActiveShift();

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'cash_shift_closed',
      referenceId: closedShift.id,
      description: `Cash shift closed. Difference: ${difference}`,
    });

    return {
      success: true,
      message: 'Cash shift closed successfully',
      data: closedShift,
    };
  }

  async recordCashTransaction(
    dto: CashTransactionDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CashShiftRecord>> {
    const active = await this.financeSettings.getActiveShift();

    if (!active || active.status !== 'OPEN') {
      throw new BadRequestException('No active cash shift');
    }

    const updated: CashShiftRecord = {
      ...active,
      totalCashIn:
        dto.type === 'CASH_IN'
          ? active.totalCashIn + dto.amount
          : active.totalCashIn,
      totalCashOut:
        dto.type === 'CASH_OUT'
          ? active.totalCashOut + dto.amount
          : active.totalCashOut,
    };

    await this.financeSettings.saveActiveShift(updated);

    await this.prisma.cashflow.create({
      data: {
        type:
          dto.type === 'CASH_IN' ? CashflowType.INCOME : CashflowType.EXPENSE,
        referenceType: ReferenceType.SYSTEM,
        referenceId: active.id,
        amount: dto.amount,
        transactionDate: new Date(),
        description: `Cash ${dto.type}: ${dto.description ?? 'Manual adjustment'}`,
        createdByEmployeeId: employeeId,
      },
    });

    return {
      success: true,
      message: 'Cash transaction recorded successfully',
      data: updated,
    };
  }

  async generateDailyClosing(
    query: DailyClosingQueryDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<DailyClosingRecord>> {
    const date =
      query.date ?? formatFinanceReferenceDate(new Date());
    const existing = await this.financeSettings.getDailyClosing(date);

    if (existing) {
      return {
        success: true,
        message: 'Daily closing retrieved successfully',
        data: existing,
      };
    }

    const start = new Date(
      `${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6, 8)}T00:00:00.000Z`,
    );
    const end = new Date(
      `${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6, 8)}T23:59:59.999Z`,
    );

    const [income, expense, refund] = await this.prisma.$transaction([
      this.prisma.cashflow.aggregate({
        where: {
          type: CashflowType.INCOME,
          transactionDate: { gte: start, lte: end },
        },
        _sum: { amount: true },
      }),
      this.prisma.cashflow.aggregate({
        where: {
          type: CashflowType.EXPENSE,
          referenceType: ReferenceType.EXPENSE,
          transactionDate: { gte: start, lte: end },
        },
        _sum: { amount: true },
      }),
      this.prisma.cashflow.aggregate({
        where: {
          type: CashflowType.EXPENSE,
          referenceType: ReferenceType.REFUND,
          transactionDate: { gte: start, lte: end },
        },
        _sum: { amount: true },
      }),
    ]);

    const activeShift = await this.financeSettings.getActiveShift();
    const openingCash = activeShift?.openingCash ?? 0;
    const incomeAmount = Number(income._sum.amount ?? 0);
    const expenseAmount = Number(expense._sum.amount ?? 0);
    const refundAmount = Number(refund._sum.amount ?? 0);
    const closingCash = openingCash + incomeAmount - expenseAmount - refundAmount;

    const record: DailyClosingRecord = {
      closingDate: date,
      openingCash,
      income: incomeAmount,
      expense: expenseAmount,
      refund: refundAmount,
      closingCash,
      generatedAt: new Date().toISOString(),
      generatedByEmployeeId: employeeId,
    };

    await this.financeSettings.saveDailyClosing(record);

    return {
      success: true,
      message: 'Daily closing generated successfully',
      data: record,
    };
  }

  async adjustIncome(
    dto: AdjustIncomeDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<{ amount: number; description: string }>> {
    if (!roles.includes('OWNER')) {
      throw new ForbiddenException('Only owner can adjust income manually');
    }

    await this.prisma.cashflow.create({
      data: {
        type: CashflowType.INCOME,
        referenceType: ReferenceType.SYSTEM,
        referenceId: randomUUID(),
        amount: dto.amount,
        transactionDate: new Date(),
        description: `Manual income adjustment: ${dto.description}`,
        createdByEmployeeId: employeeId,
      },
    });

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'income_adjusted',
      description: `Manual income adjustment ${dto.amount}`,
    });

    return {
      success: true,
      message: 'Income adjustment recorded successfully',
      data: {
        amount: dto.amount,
        description: dto.description,
      },
    };
  }

  async validateVoucher(
    dto: ValidateVoucherDto,
  ): Promise<
    ApiSuccessResponse<{
      valid: boolean;
      code: string;
      discountType: string;
      discountValue: number;
      estimatedDiscount: number;
      remainingUsage: number;
      expiresAt: string;
    }>
  > {
    const voucher = await this.financeSettings.getVoucher(dto.code);

    if (!voucher || !voucher.isActive || isVoucherExpired(voucher)) {
      throw new BadRequestException('Voucher is invalid or expired');
    }

    const remainingUsage = getVoucherRemainingUsage(voucher);

    if (remainingUsage <= 0) {
      throw new BadRequestException('Voucher usage limit reached');
    }

    const orderAmount = dto.orderAmount ?? 0;
    const estimatedDiscount = this.calculateVoucherDiscount(voucher, orderAmount);

    return {
      success: true,
      message: 'Voucher is valid',
      data: {
        valid: true,
        code: voucher.code,
        discountType: voucher.type,
        discountValue: voucher.value,
        estimatedDiscount,
        remainingUsage,
        expiresAt: voucher.expiresAt,
      },
    };
  }

  async createVoucher(
    dto: CreateVoucherDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<VoucherRecord>> {
    if (!roles.includes('OWNER') && !roles.includes('MANAGER')) {
      throw new ForbiddenException('Insufficient permissions to create voucher');
    }

    const existing = await this.financeSettings.getVoucher(dto.code);

    if (existing) {
      throw new BadRequestException('Voucher code already exists');
    }

    const record: VoucherRecord = {
      code: dto.code.trim().toUpperCase(),
      type: dto.type,
      value: dto.value,
      expiresAt: dto.expiresAt.toISOString(),
      maxUsage: dto.maxUsage,
      usedCount: 0,
      isActive: true,
      createdAt: new Date().toISOString(),
      createdByEmployeeId: employeeId,
    };

    await this.financeSettings.saveVoucher(record);

    return {
      success: true,
      message: 'Voucher created successfully',
      data: record,
    };
  }

  private calculateVoucherDiscount(
    voucher: VoucherRecord,
    orderAmount: number,
  ): number {
    if (orderAmount <= 0) {
      return 0;
    }

    if (voucher.type === 'PERCENTAGE') {
      return Number(((orderAmount * voucher.value) / 100).toFixed(2));
    }

    return Math.min(voucher.value, orderAmount);
  }
}
