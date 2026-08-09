import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  CashflowType,
  PayrollRecordStatus,
  ReferenceType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { FinanceAuditService } from '../finance/finance-audit.service';
import { PayrollCalculatorService } from './payroll-calculator.service';
import {
  ApprovePayrollDto,
  CalculatePayrollDto,
  PayPayrollDto,
  PayrollQueryDto,
  PayrollReportQueryDto,
} from './payroll.dto';
import { toPayrollDetail, toPayrollListItem } from './payroll.mapper';
import { PayrollRepository } from './payroll.repository';
import {
  DEFAULT_PAYROLL_SETTINGS,
  PAYROLL_LATEST_TOTAL_KEY,
  PAYROLL_SETTINGS_KEY,
  PayrollSettings,
} from './payroll.types';

@Injectable()
export class PayrollService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly repository: PayrollRepository,
    private readonly calculator: PayrollCalculatorService,
    private readonly auditService: FinanceAuditService,
  ) {}

  async getSettings(): Promise<PayrollSettings> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: PAYROLL_SETTINGS_KEY },
    });

    if (!setting) return DEFAULT_PAYROLL_SETTINGS;

    const parsed = JSON.parse(setting.settingValue) as Partial<PayrollSettings>;
    return this.normalizeSettings(parsed);
  }

  async updateSettings(
    dto: Partial<PayrollSettings>,
    employeeId: string,
    options?: { skipAudit?: boolean },
  ): Promise<PayrollSettings> {
    const current = await this.getSettings();
    const next = this.normalizeSettings({
      ...current,
      ...dto,
      attendanceBonus: {
        ...current.attendanceBonus,
        ...(dto.attendanceBonus ?? {}),
      },
    });

    await this.prisma.systemSetting.upsert({
      where: { settingKey: PAYROLL_SETTINGS_KEY },
      create: {
        settingKey: PAYROLL_SETTINGS_KEY,
        settingValue: JSON.stringify(next),
        description: 'Payroll configuration',
      },
      update: { settingValue: JSON.stringify(next) },
    });

    if (!options?.skipAudit) {
      await this.auditService.log({
        employeeId,
        module: 'payroll',
        action: 'update_settings',
        description: 'Payroll settings updated',
      });
    }

    return next;
  }

  async getDashboard() {
    const settings = await this.getSettings();
    const { periodStart, periodEnd } = this.getCurrentPeriod(settings);
    const aggregates = await this.repository.aggregateDashboard(
      periodStart,
      periodEnd,
    );

    let waiting = 0;
    let estimated = 0;
    let paid = 0;
    let totalBonus = 0;
    let totalDeduction = 0;

    for (const row of aggregates) {
      const count = row._count._all ?? 0;
      const net = Number(row._sum.netSalary ?? 0);
      const bonus = Number(row._sum.totalBonus ?? 0);
      const deduction = Number(row._sum.totalDeduction ?? 0);

      totalBonus += bonus;
      totalDeduction += deduction;

      if (row.status === PayrollRecordStatus.PAID) {
        paid += net;
      } else if (
        row.status === PayrollRecordStatus.DRAFT ||
        row.status === PayrollRecordStatus.CALCULATED
      ) {
        waiting += count;
        estimated += net;
      }
    }

    return {
      currentPeriod: {
        start: periodStart.toISOString().slice(0, 10),
        end: periodEnd.toISOString().slice(0, 10),
      },
      employeesWaitingPayroll: waiting,
      estimatedPayroll: estimated,
      paidPayroll: paid,
      totalBonus,
      totalDeduction,
    };
  }

  async findAll(query: PayrollQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 25;
    const [records, total] = await this.repository.findMany(query);

    return {
      items: records.map(toPayrollListItem),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  async findOne(id: string) {
    const record = await this.repository.findById(id);
    if (!record) throw new NotFoundException('Payroll record not found');
    return toPayrollDetail(record);
  }

  async calculate(dto: CalculatePayrollDto, actorEmployeeId: string) {
    if (dto.periodEnd < dto.periodStart) {
      throw new BadRequestException('Period end must be after period start');
    }

    const settings = await this.getSettings();
    const employees = await this.prisma.employee.findMany({
      where: { deletedAt: null, status: 'active' },
      include: {
        employeeRoles: {
          where: { deletedAt: null },
          include: { role: true },
        },
      },
    });

    const results = [];

    for (const employee of employees) {
      const role = this.calculator.resolveEmployeeRole(employee.employeeRoles);
      const attendance = await this.calculator.calculateAttendance(
        employee.id,
        dto.periodStart,
        dto.periodEnd,
      );
      const production = await this.calculator.calculateProduction(
        employee.id,
        dto.periodStart,
        dto.periodEnd,
        settings,
      );

      const attendanceBonus = this.calculator.calculateAttendanceBonus(
        attendance,
        settings,
      );
      const baseSalary = this.calculator.resolveBaseSalary(role, settings);
      const totalBonus = attendanceBonus;
      const totalDeduction = 0;
      const grossSalary = baseSalary + production.productionSalary + totalBonus;
      const netSalary = production.productionSalary + totalBonus - totalDeduction + baseSalary;

      const existing = await this.prisma.payrollRecord.findFirst({
        where: {
          employeeId: employee.id,
          periodStart: dto.periodStart,
          periodEnd: dto.periodEnd,
          deletedAt: null,
        },
      });

      const payrollNumber =
        existing?.payrollNumber ??
        (await this.repository.nextPayrollNumber(dto.periodEnd));

      const record = existing
        ? await this.repository.updateRecord(existing.id, {
            role,
            status: PayrollRecordStatus.CALCULATED,
            laundryKg: production.laundryKg,
            laundryPiece: production.laundryPiece,
            ironingKg: production.ironingKg,
            ironingPiece: production.ironingPiece,
            ordersFinished: production.ordersFinished,
            productionSalary: production.productionSalary,
            presentDays: attendance.presentDays,
            absentDays: attendance.absentDays,
            lateDays: attendance.lateDays,
            leaveDays: attendance.leaveDays,
            baseSalary,
            grossSalary,
            totalBonus,
            totalDeduction,
            netSalary,
            calculatedAt: new Date(),
            calculatedByEmployeeId: actorEmployeeId,
          })
        : await this.repository.createRecord({
            payrollNumber,
            employee: { connect: { id: employee.id } },
            periodStart: dto.periodStart,
            periodEnd: dto.periodEnd,
            role,
            status: PayrollRecordStatus.CALCULATED,
            laundryKg: production.laundryKg,
            laundryPiece: production.laundryPiece,
            ironingKg: production.ironingKg,
            ironingPiece: production.ironingPiece,
            ordersFinished: production.ordersFinished,
            productionSalary: production.productionSalary,
            presentDays: attendance.presentDays,
            absentDays: attendance.absentDays,
            lateDays: attendance.lateDays,
            leaveDays: attendance.leaveDays,
            baseSalary,
            grossSalary,
            totalBonus,
            totalDeduction,
            netSalary,
            calculatedAt: new Date(),
            calculatedByEmployeeId: actorEmployeeId,
          });

      await this.repository.replaceBonuses(record.id, [
        {
          type: 'ATTENDANCE',
          amount: attendanceBonus,
          notes: `${attendance.presentDays} present day(s)`,
        },
      ]);

      await this.repository.addApprovalEvent({
        payrollRecordId: record.id,
        status: PayrollRecordStatus.CALCULATED,
        actorEmployeeId,
        notes: 'Payroll calculated',
      });

      const refreshed = await this.repository.findById(record.id);
      if (refreshed) results.push(toPayrollListItem(refreshed));
    }

    const totalAmount = results.reduce((sum, item) => sum + item.netSalary, 0);
    await this.prisma.systemSetting.upsert({
      where: { settingKey: PAYROLL_LATEST_TOTAL_KEY },
      create: {
        settingKey: PAYROLL_LATEST_TOTAL_KEY,
        settingValue: JSON.stringify({ total: totalAmount }),
        description: 'Latest payroll total',
      },
      update: {
        settingValue: JSON.stringify({ total: totalAmount }),
      },
    });

    await this.auditService.log({
      employeeId: actorEmployeeId,
      module: 'payroll',
      action: 'calculate_payroll',
      description: `Calculated payroll ${dto.periodStart.toISOString()} - ${dto.periodEnd.toISOString()}`,
    });

    return results;
  }

  async approve(
    dto: ApprovePayrollDto,
    actorEmployeeId: string,
    actorRoles: string[],
  ) {
    if (!actorRoles.includes('OWNER')) {
      throw new ForbiddenException('Only OWNER can approve payroll');
    }

    const approved = [];
    for (const payrollId of dto.payrollIds) {
      const record = await this.repository.findById(payrollId);
      if (!record) throw new NotFoundException(`Payroll ${payrollId} not found`);
      if (record.status !== PayrollRecordStatus.CALCULATED) {
        throw new BadRequestException(
          `Payroll ${record.payrollNumber} must be CALCULATED before approval`,
        );
      }

      const updated = await this.repository.updateRecord(payrollId, {
        status: PayrollRecordStatus.APPROVED,
        approvedAt: new Date(),
        approvedByEmployeeId: actorEmployeeId,
      });

      await this.repository.addApprovalEvent({
        payrollRecordId: payrollId,
        status: PayrollRecordStatus.APPROVED,
        actorEmployeeId,
        notes: dto.notes ?? 'Payroll approved',
      });

      approved.push(toPayrollListItem(updated));
    }

    return approved;
  }

  async pay(dto: PayPayrollDto, actorEmployeeId: string) {
    const record = await this.repository.findById(dto.payrollId);
    if (!record) throw new NotFoundException('Payroll record not found');
    if (record.status !== PayrollRecordStatus.APPROVED) {
      throw new BadRequestException('Payroll must be approved before payment');
    }

    await this.repository.addPayment({
      payrollRecordId: dto.payrollId,
      method: dto.method,
      amount: dto.amount,
      referenceNumber: dto.referenceNumber,
      notes: dto.notes,
      paidAt: new Date(),
      paidByEmployeeId: actorEmployeeId,
    });

    await this.repository.updateRecord(dto.payrollId, {
      status: PayrollRecordStatus.PAID,
      paidAt: new Date(),
      paidByEmployeeId: actorEmployeeId,
    });

    await this.repository.addApprovalEvent({
      payrollRecordId: dto.payrollId,
      status: PayrollRecordStatus.PAID,
      actorEmployeeId,
      notes: dto.notes ?? `Paid via ${dto.method}`,
    });

    await this.prisma.cashflow.create({
      data: {
        type: CashflowType.EXPENSE,
        referenceType: ReferenceType.PAYROLL,
        referenceId: dto.payrollId,
        amount: dto.amount,
        transactionDate: new Date(),
        description: `Payroll payment ${record.payrollNumber}`,
        createdByEmployeeId: actorEmployeeId,
      },
    });

    const refreshed = await this.repository.findById(dto.payrollId);
    return refreshed ? toPayrollDetail(refreshed) : null;
  }

  async getReport(query: PayrollReportQueryDto) {
    const records = await this.prisma.payrollRecord.findMany({
      where: {
        deletedAt: null,
        ...(query.periodStart ? { periodStart: query.periodStart } : {}),
        ...(query.periodEnd ? { periodEnd: query.periodEnd } : {}),
      },
      include: {
        employee: { select: { fullName: true, employeeCode: true } },
        bonuses: true,
        deductions: true,
      },
    });

    const summary = {
      totalRecords: records.length,
      totalGross: records.reduce((sum, r) => sum + Number(r.grossSalary), 0),
      totalNet: records.reduce((sum, r) => sum + Number(r.netSalary), 0),
      totalBonus: records.reduce((sum, r) => sum + Number(r.totalBonus), 0),
      totalDeduction: records.reduce((sum, r) => sum + Number(r.totalDeduction), 0),
      paidCount: records.filter((r) => r.status === PayrollRecordStatus.PAID).length,
    };

    if (query.reportType === 'bonus') {
      return {
        summary,
        items: records.flatMap((record) =>
          record.bonuses.map((bonus) => ({
            payrollNumber: record.payrollNumber,
            employeeName: record.employee.fullName,
            type: bonus.type,
            amount: Number(bonus.amount),
            notes: bonus.notes,
          })),
        ),
      };
    }

    if (query.reportType === 'deduction') {
      return {
        summary,
        items: records.flatMap((record) =>
          record.deductions.map((deduction) => ({
            payrollNumber: record.payrollNumber,
            employeeName: record.employee.fullName,
            type: deduction.type,
            amount: Number(deduction.amount),
            notes: deduction.notes,
          })),
        ),
      };
    }

    if (query.reportType === 'detail') {
      return {
        summary,
        items: records.map((record) => ({
          payrollNumber: record.payrollNumber,
          employeeName: record.employee.fullName,
          employeeCode: record.employee.employeeCode,
          netSalary: Number(record.netSalary),
          status: record.status,
        })),
      };
    }

    return { summary };
  }

  getCurrentPeriod(settings: PayrollSettings) {
    const today = new Date();
    const schedule = [...settings.payrollScheduleDays].sort((a, b) => a - b);
    const day = today.getDate();
    let startDay = schedule[0];
    let endDay = schedule[schedule.length - 1];

    for (let index = 0; index < schedule.length; index += 1) {
      const current = schedule[index];
      const next = schedule[index + 1] ?? 32;
      if (day >= current && day < next) {
        startDay = current;
        endDay = next - 1;
        break;
      }
    }

    const periodStart = new Date(today.getFullYear(), today.getMonth(), startDay);
    const periodEnd = new Date(today.getFullYear(), today.getMonth(), endDay);
    return { periodStart, periodEnd };
  }

  private normalizeSettings(
    input: Partial<PayrollSettings> & {
      laundryPricePerKg?: number;
      laundryPricePerItem?: number;
    },
  ): PayrollSettings {
    return {
      ...DEFAULT_PAYROLL_SETTINGS,
      ...input,
      laundryKgRate:
        input.laundryKgRate ?? input.laundryPricePerKg ?? DEFAULT_PAYROLL_SETTINGS.laundryKgRate,
      laundryPieceRate:
        input.laundryPieceRate ??
        input.laundryPricePerItem ??
        DEFAULT_PAYROLL_SETTINGS.laundryPieceRate,
      ironingKgRate: input.ironingKgRate ?? DEFAULT_PAYROLL_SETTINGS.ironingKgRate,
      ironingPieceRate:
        input.ironingPieceRate ?? DEFAULT_PAYROLL_SETTINGS.ironingPieceRate,
      attendanceBonusPerDay:
        input.attendanceBonusPerDay ??
        input.attendanceBonus?.bonusAmount ??
        DEFAULT_PAYROLL_SETTINGS.attendanceBonusPerDay,
      attendanceBonus: {
        ...DEFAULT_PAYROLL_SETTINGS.attendanceBonus,
        ...(input.attendanceBonus ?? {}),
        bonusAmount:
          input.attendanceBonus?.bonusAmount ??
          input.attendanceBonusPerDay ??
          DEFAULT_PAYROLL_SETTINGS.attendanceBonusPerDay,
      },
    };
  }
}
