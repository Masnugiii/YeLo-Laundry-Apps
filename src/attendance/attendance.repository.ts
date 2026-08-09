import { Injectable } from '@nestjs/common';
import {
  AttendanceActivityType,
  AttendanceStatus,
  EmployeeStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { AttendanceQueryDto } from './dto/attendance.dto';
import {
  attendanceDetailSelect,
  attendanceListSelect,
  AttendanceDetailRecord,
} from './attendance.select';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import {
  AttendanceMeta,
  calculateBreakMinutes,
  decodeAttendanceNotes,
  encodeAttendanceNotes,
} from './utils/attendance-meta.util';
import {
  formatDateKey,
  getAttendanceDate,
  getMinutesFromDate,
  getMinutesFromTimeValue,
} from './utils/attendance-date.util';
import { isWithinRadius } from './utils/gps.util';
import { parseTimeToMinutes } from './utils/shift-meta.util';

export interface CheckInInput {
  employeeId: string;
  latitude: number;
  longitude: number;
  accuracy?: number;
  photoUrl?: string;
  device?: string;
  notes?: string;
  shiftId?: string;
}

export interface CheckOutInput {
  employeeId: string;
  latitude: number;
  longitude: number;
  accuracy?: number;
  photoUrl?: string;
  notes?: string;
}

@Injectable()
export class AttendanceRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settingsRepository: AttendanceSettingsRepository,
  ) {}

  findMany(query: AttendanceQueryDto, scopedEmployeeId?: string) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query, scopedEmployeeId);

    return this.prisma.$transaction([
      this.prisma.attendance.findMany({
        where,
        skip,
        take: limit,
        orderBy: { attendanceDate: 'desc' },
        select: attendanceListSelect,
      }),
      this.prisma.attendance.count({ where }),
    ]);
  }

  findById(id: string): Promise<AttendanceDetailRecord | null> {
    return this.prisma.attendance.findFirst({
      where: { id, deletedAt: null },
      select: attendanceDetailSelect,
    });
  }

  findTodayAttendance(employeeId: string, date = getAttendanceDate()) {
    return this.prisma.attendance.findFirst({
      where: {
        employeeId,
        attendanceDate: date,
        deletedAt: null,
      },
      select: attendanceDetailSelect,
    });
  }

  async validateGps(latitude: number, longitude: number): Promise<void> {
    const config = await this.settingsRepository.getGpsConfig();

    if (!config) {
      return;
    }

    const within = isWithinRadius(
      latitude,
      longitude,
      config.officeLatitude,
      config.officeLongitude,
      config.officeRadiusMeters,
    );

    if (!within) {
      throw new Error('OUT_OF_RADIUS');
    }
  }

  checkIn(input: CheckInInput): Promise<AttendanceDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const attendanceDate = getAttendanceDate();
      const now = new Date();

      const existing = await tx.attendance.findFirst({
        where: {
          employeeId: input.employeeId,
          attendanceDate,
          deletedAt: null,
        },
        select: { id: true, checkIn: true, checkOut: true },
      });

      if (existing?.checkIn && !existing.checkOut) {
        throw new Error('ALREADY_CHECKED_IN');
      }

      if (existing?.checkIn && existing.checkOut) {
        throw new Error('ALREADY_COMPLETED');
      }

      const [setting, shift, holiday, approvedLeave] = await Promise.all([
        tx.attendanceSetting.findFirst({
          where: { isActive: true },
          orderBy: { createdAt: 'desc' },
        }),
        input.shiftId
          ? this.settingsRepository.getShift(input.shiftId)
          : this.settingsRepository.listShifts(true).then((shifts) => shifts[0] ?? null),
        this.settingsRepository.getHolidayForDate(attendanceDate),
        this.settingsRepository.getApprovedLeaveForDate(
          input.employeeId,
          attendanceDate,
        ),
      ]);

      if (holiday) {
        throw new Error('HOLIDAY');
      }

      if (approvedLeave) {
        throw new Error('ON_LEAVE');
      }

      const shiftStartMinutes = shift
        ? parseTimeToMinutes(shift.startTime)
        : setting
          ? getMinutesFromTimeValue(setting.workStartTime)
          : 8 * 60;
      const tolerance = shift?.toleranceMinutes ?? setting?.lateToleranceMinutes ?? 0;
      const checkInMinutes = getMinutesFromDate(now);
      const lateMinutes = Math.max(0, checkInMinutes - shiftStartMinutes - tolerance);
      const status =
        lateMinutes > 0 ? AttendanceStatus.LATE : AttendanceStatus.PRESENT;

      const meta: AttendanceMeta = {
        shiftId: input.shiftId ?? shift?.id,
        checkInPhotoUrl: input.photoUrl,
        checkInNotes: input.notes,
        checkInAccuracy: input.accuracy,
        breakSessions: [],
        breakMinutes: 0,
        overtimeMinutes: 0,
        earlyLeaveMinutes: 0,
      };

      let attendance: AttendanceDetailRecord;

      if (existing) {
        attendance = await tx.attendance.update({
          where: { id: existing.id },
          data: {
            checkIn: now,
            checkOut: null,
            workingMinutes: null,
            lateMinutes,
            status,
            notes: encodeAttendanceNotes(meta, input.notes),
          },
          select: attendanceDetailSelect,
        });
      } else {
        attendance = await tx.attendance.create({
          data: {
            employeeId: input.employeeId,
            attendanceDate,
            checkIn: now,
            lateMinutes,
            status,
            notes: encodeAttendanceNotes(meta, input.notes),
          },
          select: attendanceDetailSelect,
        });
      }

      await tx.attendanceLog.create({
        data: {
          attendanceId: attendance.id,
          employeeId: input.employeeId,
          activityType: AttendanceActivityType.CHECK_IN,
          activityTime: now,
          latitude: input.latitude,
          longitude: input.longitude,
          deviceInfo: input.device,
        },
      });

      return attendance;
    });
  }

  checkOut(input: CheckOutInput): Promise<AttendanceDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const attendanceDate = getAttendanceDate();
      const now = new Date();

      const attendance = await tx.attendance.findFirst({
        where: {
          employeeId: input.employeeId,
          attendanceDate,
          deletedAt: null,
        },
        select: {
          id: true,
          checkIn: true,
          checkOut: true,
          notes: true,
          lateMinutes: true,
          status: true,
        },
      });

      if (!attendance?.checkIn) {
        throw new Error('NOT_CHECKED_IN');
      }

      if (attendance.checkOut) {
        throw new Error('ALREADY_CHECKED_OUT');
      }

      const { meta, notes } = decodeAttendanceNotes(attendance.notes);
      const closedMeta = this.closeActiveBreak(meta, now);
      const breakMinutes = calculateBreakMinutes(closedMeta);

      const [setting, shift] = await Promise.all([
        tx.attendanceSetting.findFirst({
          where: { isActive: true },
          orderBy: { createdAt: 'desc' },
        }),
        closedMeta.shiftId
          ? this.settingsRepository.getShift(closedMeta.shiftId)
          : this.settingsRepository.listShifts(true).then((shifts) => shifts[0] ?? null),
      ]);

      const checkInTime = attendance.checkIn!;
      const totalMinutes = Math.max(
        0,
        Math.round((now.getTime() - checkInTime.getTime()) / 60000) -
          breakMinutes,
      );

      const shiftEndMinutes = shift
        ? parseTimeToMinutes(shift.endTime)
        : setting
          ? getMinutesFromTimeValue(setting.workEndTime)
          : 17 * 60;
      const checkOutMinutes = getMinutesFromDate(now);
      const overtimeEnabled = setting?.overtimeEnabled ?? false;
      const overtimeMinutes =
        overtimeEnabled && checkOutMinutes > shiftEndMinutes
          ? checkOutMinutes - shiftEndMinutes
          : 0;
      const earlyLeaveMinutes =
        checkOutMinutes < shiftEndMinutes
          ? shiftEndMinutes - checkOutMinutes
          : 0;

      const updatedMeta: AttendanceMeta = {
        ...closedMeta,
        checkOutPhotoUrl: input.photoUrl,
        checkOutNotes: input.notes,
        checkOutAccuracy: input.accuracy,
        breakMinutes,
        overtimeMinutes,
        earlyLeaveMinutes,
      };

      const updated = await tx.attendance.update({
        where: { id: attendance.id },
        data: {
          checkOut: now,
          workingMinutes: totalMinutes,
          notes: encodeAttendanceNotes(updatedMeta, notes),
        },
        select: attendanceDetailSelect,
      });

      await tx.attendanceLog.create({
        data: {
          attendanceId: attendance.id,
          employeeId: input.employeeId,
          activityType: AttendanceActivityType.CHECK_OUT,
          activityTime: now,
          latitude: input.latitude,
          longitude: input.longitude,
        },
      });

      return updated;
    });
  }

  startBreak(employeeId: string, notes?: string): Promise<AttendanceDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const attendance = await this.getOpenAttendance(tx, employeeId);
      const { meta, notes: body } = decodeAttendanceNotes(attendance.notes);

      if (meta.activeBreakStart) {
        throw new Error('BREAK_ACTIVE');
      }

      const now = new Date().toISOString();
      const updatedMeta: AttendanceMeta = {
        ...meta,
        activeBreakStart: now,
        breakSessions: [...(meta.breakSessions ?? []), { start: now }],
      };

      return tx.attendance.update({
        where: { id: attendance.id },
        data: {
          notes: encodeAttendanceNotes(updatedMeta, notes ?? body),
        },
        select: attendanceDetailSelect,
      });
    });
  }

  endBreak(employeeId: string, notes?: string): Promise<AttendanceDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const attendance = await this.getOpenAttendance(tx, employeeId);
      const { meta, notes: body } = decodeAttendanceNotes(attendance.notes);

      if (!meta.activeBreakStart) {
        throw new Error('NO_ACTIVE_BREAK');
      }

      const now = new Date();
      const closedMeta = this.closeActiveBreak(meta, now);

      return tx.attendance.update({
        where: { id: attendance.id },
        data: {
          notes: encodeAttendanceNotes(closedMeta, notes ?? body),
        },
        select: attendanceDetailSelect,
      });
    });
  }

  getDashboardMetrics(date = getAttendanceDate()) {
    const start = date;
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    return this.prisma.$transaction([
      this.prisma.attendance.count({
        where: {
          attendanceDate: start,
          deletedAt: null,
          status: { in: [AttendanceStatus.PRESENT, AttendanceStatus.LATE] },
          checkIn: { not: null },
        },
      }),
      this.prisma.attendance.count({
        where: {
          attendanceDate: start,
          deletedAt: null,
          status: AttendanceStatus.LATE,
        },
      }),
      this.prisma.employee.count({
        where: { status: EmployeeStatus.active, deletedAt: null },
      }),
      this.prisma.attendance.aggregate({
        where: {
          attendanceDate: start,
          deletedAt: null,
          workingMinutes: { not: null },
        },
        _avg: { workingMinutes: true },
        _sum: { workingMinutes: true },
      }),
    ]);
  }

  private async getOpenAttendance(
    tx: Prisma.TransactionClient,
    employeeId: string,
  ) {
    const attendance = await tx.attendance.findFirst({
      where: {
        employeeId,
        attendanceDate: getAttendanceDate(),
        deletedAt: null,
      },
      select: {
        id: true,
        checkIn: true,
        checkOut: true,
        notes: true,
      },
    });

    if (!attendance?.checkIn || attendance.checkOut) {
      throw new Error('NOT_CHECKED_IN');
    }

    return attendance;
  }

  private closeActiveBreak(meta: AttendanceMeta, endTime: Date): AttendanceMeta {
    if (!meta.activeBreakStart) {
      return meta;
    }

    const endIso = endTime.toISOString();
    const sessions = [...(meta.breakSessions ?? [])];
    const lastIndex = sessions.findIndex(
      (session) => session.start === meta.activeBreakStart && !session.end,
    );

    if (lastIndex >= 0) {
      sessions[lastIndex] = { ...sessions[lastIndex], end: endIso };
    }

    return {
      ...meta,
      activeBreakStart: undefined,
      breakSessions: sessions,
      breakMinutes: calculateBreakMinutes({
        ...meta,
        activeBreakStart: undefined,
        breakSessions: sessions,
      }),
    };
  }

  private buildWhereClause(
    query: AttendanceQueryDto,
    scopedEmployeeId?: string,
  ): Prisma.AttendanceWhereInput {
    const where: Prisma.AttendanceWhereInput = { deletedAt: null };

    if (scopedEmployeeId) {
      where.employeeId = scopedEmployeeId;
    } else if (query.employeeId) {
      where.employeeId = query.employeeId;
    }

    if (query.status) {
      where.status = query.status;
    }

    if (query.date) {
      where.attendanceDate = getAttendanceDate(query.date);
    } else if (query.dateFrom || query.dateTo) {
      where.attendanceDate = {
        ...(query.dateFrom ? { gte: getAttendanceDate(query.dateFrom) } : {}),
        ...(query.dateTo ? { lte: getAttendanceDate(query.dateTo) } : {}),
      };
    }

    if (query.shiftId) {
      where.notes = { contains: `"shiftId":"${query.shiftId}"` };
    }

    if (query.search) {
      const search = query.search.trim();
      where.employee = {
        OR: [
          { fullName: { contains: search, mode: 'insensitive' } },
          { employeeCode: { contains: search, mode: 'insensitive' } },
        ],
      };
    }

    return where;
  }
}
