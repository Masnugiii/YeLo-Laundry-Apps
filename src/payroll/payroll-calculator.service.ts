import { Injectable } from '@nestjs/common';
import { AttendanceStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  parseProductionRecord,
  PRODUCTION_SETTING_PREFIX,
  ProductionStatus,
} from '../laundry/utils/production-meta.util';
import { mapRoleCode } from '../auth/utils/role.util';
import {
  AttendanceSummary,
  PayrollSettings,
  ProductionSummary,
} from './payroll.types';

const LAUNDRY_STAGES: ProductionStatus[] = ['WASHING', 'DRYING'];
const IRONING_STAGES: ProductionStatus[] = ['IRONING'];

@Injectable()
export class PayrollCalculatorService {
  constructor(private readonly prisma: PrismaService) {}

  async calculateAttendance(
    employeeId: string,
    periodStart: Date,
    periodEnd: Date,
  ): Promise<AttendanceSummary> {
    const records = await this.prisma.attendance.findMany({
      where: {
        employeeId,
        deletedAt: null,
        attendanceDate: { gte: periodStart, lte: periodEnd },
      },
    });

    return {
      presentDays: records.filter(
        (record) =>
          record.status === AttendanceStatus.PRESENT ||
          record.status === AttendanceStatus.LATE,
      ).length,
      absentDays: records.filter(
        (record) => record.status === AttendanceStatus.ABSENT,
      ).length,
      lateDays: records.filter(
        (record) =>
          record.status === AttendanceStatus.LATE ||
          (record.lateMinutes ?? 0) > 0,
      ).length,
      leaveDays: records.filter(
        (record) =>
          record.status === AttendanceStatus.LEAVE ||
          record.status === AttendanceStatus.SICK,
      ).length,
    };
  }

  async calculateProduction(
    employeeId: string,
    periodStart: Date,
    periodEnd: Date,
    settings: PayrollSettings,
  ): Promise<ProductionSummary> {
    const [productionSettings, ironingJobs, contributions] = await Promise.all([
      this.prisma.systemSetting.findMany({
        where: { settingKey: { startsWith: PRODUCTION_SETTING_PREFIX } },
        select: { settingValue: true },
      }),
      this.prisma.ironingJob.findMany({
        where: {
          employeeId,
          deletedAt: null,
          finishedAt: { gte: periodStart, lte: periodEnd },
        },
        include: {
          order: {
            include: {
              items: {
                where: { deletedAt: null },
                include: { service: true },
              },
            },
          },
        },
      }),
      this.prisma.ironingContribution.findMany({
        where: {
          employeeId,
          helpFinishedAt: { gte: periodStart, lte: periodEnd },
        },
        include: {
          ironingJob: {
            include: {
              order: {
                include: {
                  items: {
                    where: { deletedAt: null },
                    include: { service: true },
                  },
                },
              },
            },
          },
        },
      }),
    ]);

    const laundryOrderIds = new Set<string>();
    let laundryKg = 0;
    let laundryPiece = 0;

    for (const setting of productionSettings) {
      const record = parseProductionRecord(setting.settingValue);
      if (!record) continue;

      const relevantEvents = record.history.filter((event) => {
        if (!LAUNDRY_STAGES.includes(event.stage)) return false;
        if (event.employeeId !== employeeId) return false;
        const finishedAt = event.finishedAt ? new Date(event.finishedAt) : null;
        const startedAt = new Date(event.startedAt);
        const point = finishedAt ?? startedAt;
        return point >= periodStart && point <= periodEnd;
      });

      if (relevantEvents.length === 0) continue;
      laundryOrderIds.add(record.orderId);

      const order = await this.prisma.order.findUnique({
        where: { id: record.orderId },
        include: {
          items: {
            where: { deletedAt: null },
            include: { service: true },
          },
        },
      });

      if (!order) continue;

      for (const item of order.items) {
        const unitType = item.service.unitType;
        if (unitType === 'kg' || item.weight) {
          laundryKg += Number(item.weight ?? 0);
        } else {
          laundryPiece += Number(item.quantity ?? 0);
        }
      }
    }

    let ironingKg = 0;
    let ironingPiece = 0;
    const ironingOrderIds = new Set<string>();

    const accumulateIroningOrder = (order: {
      id: string;
      items: Array<{
        quantity: { toString(): string };
        weight: { toString(): string } | null;
        service: { unitType: string };
      }>;
    }) => {
      ironingOrderIds.add(order.id);
      for (const item of order.items) {
        if (item.service.unitType === 'kg' || item.weight) {
          ironingKg += Number(item.weight ?? 0);
        } else {
          ironingPiece += Number(item.quantity ?? 0);
        }
      }
    };

    for (const job of ironingJobs) {
      accumulateIroningOrder(job.order);
    }

    for (const contribution of contributions) {
      if (contribution.ironingJob.order) {
        accumulateIroningOrder(contribution.ironingJob.order);
      }
    }

    const productionSalary =
      laundryKg * settings.laundryKgRate +
      laundryPiece * settings.laundryPieceRate +
      ironingKg * settings.ironingKgRate +
      ironingPiece * settings.ironingPieceRate;

    return {
      laundryKg,
      laundryPiece,
      ironingKg,
      ironingPiece,
      ordersFinished: new Set([...laundryOrderIds, ...ironingOrderIds]).size,
      productionSalary,
    };
  }

  resolveBaseSalary(role: string, settings: PayrollSettings): number {
    if (role === 'MANAGER') return settings.managerWeeklySalary;
    if (role === 'OPERATOR') return settings.operatorWeeklySalary;
    return 0;
  }

  calculateAttendanceBonus(
    attendance: AttendanceSummary,
    settings: PayrollSettings,
  ): number {
    return attendance.presentDays * settings.attendanceBonusPerDay;
  }

  resolveEmployeeRole(
    employeeRoles: Array<{ role: { code: string } }>,
  ): string {
    if (!employeeRoles.length) return 'OPERATOR';
    return mapRoleCode(employeeRoles[0].role.code as never);
  }
}
