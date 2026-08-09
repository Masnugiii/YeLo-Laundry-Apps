import { AttendanceStatus } from '@prisma/client';
import { AttendanceDetailRecord, AttendanceListRecord } from './attendance.select';
import {
  AttendanceMeta,
  calculateBreakMinutes,
  decodeAttendanceNotes,
} from './utils/attendance-meta.util';
import { formatDateKey } from './utils/attendance-date.util';

export interface AttendanceLogResponse {
  id: string;
  activityType: string;
  activityTime: Date;
  latitude: number | null;
  longitude: number | null;
  deviceInfo: string | null;
}

export interface AttendanceResponse {
  id: string;
  employeeId: string;
  employee: {
    id: string;
    fullName: string;
    employeeCode: string;
    phone: string;
  };
  attendanceDate: Date;
  checkIn: Date | null;
  checkOut: Date | null;
  workingHours: number;
  breakDurationMinutes: number;
  overtimeMinutes: number;
  earlyLeaveMinutes: number;
  lateMinutes: number;
  status: AttendanceStatus;
  displayStatus: string;
  shiftId: string | null;
  notes: string | null;
  checkInPhotoUrl: string | null;
  checkOutPhotoUrl: string | null;
  logs: AttendanceLogResponse[];
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedAttendance {
  items: AttendanceResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface AttendanceDashboard {
  presentToday: number;
  lateToday: number;
  absentToday: number;
  onLeave: number;
  averageWorkingHours: number;
  totalOvertimeMinutes: number;
  attendancePercentage: number;
}

function decimalToNumber(value: { toString(): string } | number | null): number | null {
  if (value === null) {
    return null;
  }

  return Number(value);
}

export function resolveDisplayStatus(
  status: AttendanceStatus,
  meta: AttendanceMeta,
  options?: {
    isHoliday?: boolean;
    isOnLeave?: boolean;
    isOffDay?: boolean;
  },
): string {
  if (meta.displayStatus) {
    return meta.displayStatus;
  }

  if (options?.isHoliday) {
    return 'HOLIDAY';
  }

  if (options?.isOnLeave || status === AttendanceStatus.LEAVE) {
    return 'LEAVE';
  }

  if (status === AttendanceStatus.SICK) {
    return 'LEAVE';
  }

  if (options?.isOffDay) {
    return 'OFF';
  }

  return status;
}

export function toAttendanceResponse(
  record: AttendanceListRecord | AttendanceDetailRecord,
  options?: {
    isHoliday?: boolean;
    isOnLeave?: boolean;
    isOffDay?: boolean;
  },
): AttendanceResponse {
  const { meta, notes } = decodeAttendanceNotes(record.notes);
  const breakDurationMinutes = calculateBreakMinutes(meta);

  return {
    id: record.id,
    employeeId: record.employeeId,
    employee: record.employee,
    attendanceDate: record.attendanceDate,
    checkIn: record.checkIn,
    checkOut: record.checkOut,
    workingHours: record.workingMinutes
      ? Number((record.workingMinutes / 60).toFixed(2))
      : 0,
    breakDurationMinutes,
    overtimeMinutes: meta.overtimeMinutes ?? 0,
    earlyLeaveMinutes: meta.earlyLeaveMinutes ?? 0,
    lateMinutes: record.lateMinutes,
    status: record.status,
    displayStatus: resolveDisplayStatus(record.status, meta, options),
    shiftId: meta.shiftId ?? null,
    notes,
    checkInPhotoUrl: meta.checkInPhotoUrl ?? null,
    checkOutPhotoUrl: meta.checkOutPhotoUrl ?? null,
    logs: record.logs.map((log) => ({
      id: log.id,
      activityType: log.activityType,
      activityTime: log.activityTime,
      latitude: decimalToNumber(log.latitude),
      longitude: decimalToNumber(log.longitude),
      deviceInfo: log.deviceInfo,
    })),
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  };
}

export function formatAttendanceDateKey(date: Date): string {
  return formatDateKey(date);
}
