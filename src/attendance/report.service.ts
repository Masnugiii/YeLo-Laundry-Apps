import { Injectable } from '@nestjs/common';
import { AttendanceStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AttendanceDashboard } from './attendance.mapper';
import { AttendanceRepository } from './attendance.repository';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import { decodeAttendanceNotes } from './utils/attendance-meta.util';
import { getAttendanceDate } from './utils/attendance-date.util';

@Injectable()
export class ReportService {
  constructor(
    private readonly attendanceRepository: AttendanceRepository,
    private readonly settingsRepository: AttendanceSettingsRepository,
    private readonly prisma: PrismaService,
  ) {}

  async getDashboard(): Promise<ApiSuccessResponse<AttendanceDashboard>> {
    const today = getAttendanceDate();
    const [presentToday, lateToday, activeEmployees, aggregate] =
      await this.attendanceRepository.getDashboardMetrics(today);

    const approvedLeaves = await this.settingsRepository.listLeaves({
      status: 'APPROVED',
      dateFrom: today.toISOString().slice(0, 10),
      dateTo: today.toISOString().slice(0, 10),
    });

    const onLeave = approvedLeaves.length;
    const absentToday = Math.max(activeEmployees - presentToday - onLeave, 0);
    const averageWorkingHours = aggregate._avg.workingMinutes
      ? Number((Number(aggregate._avg.workingMinutes) / 60).toFixed(2))
      : 0;

    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
    const monthRecords = await this.prisma.attendance.findMany({
      where: {
        attendanceDate: { gte: monthStart, lte: today },
        deletedAt: null,
      },
      select: { notes: true },
    });

    const totalOvertimeMinutes = monthRecords.reduce((total, record) => {
      const { meta } = decodeAttendanceNotes(record.notes);

      return total + (meta.overtimeMinutes ?? 0);
    }, 0);

    const workingDays = this.countWorkingDays(monthStart, today);
    const expectedAttendance = activeEmployees * workingDays;
    const actualAttendance = await this.prisma.attendance.count({
      where: {
        attendanceDate: { gte: monthStart, lte: today },
        deletedAt: null,
        status: {
          in: [AttendanceStatus.PRESENT, AttendanceStatus.LATE],
        },
        checkIn: { not: null },
      },
    });

    const attendancePercentage =
      expectedAttendance > 0
        ? Number(((actualAttendance / expectedAttendance) * 100).toFixed(2))
        : 0;

    return {
      success: true,
      message: 'Attendance dashboard retrieved successfully',
      data: {
        presentToday,
        lateToday,
        absentToday,
        onLeave,
        averageWorkingHours,
        totalOvertimeMinutes,
        attendancePercentage,
      },
    };
  }

  private countWorkingDays(start: Date, end: Date): number {
    let count = 0;
    const cursor = new Date(start);

    while (cursor <= end) {
      const day = cursor.getDay();

      if (day !== 0 && day !== 6) {
        count += 1;
      }

      cursor.setDate(cursor.getDate() + 1);
    }

    return count || 1;
  }
}
