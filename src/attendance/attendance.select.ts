import { Prisma } from '@prisma/client';

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
  phone: true,
} satisfies Prisma.EmployeeSelect;

export const attendanceListSelect = {
  id: true,
  employeeId: true,
  attendanceDate: true,
  checkIn: true,
  checkOut: true,
  workingMinutes: true,
  lateMinutes: true,
  status: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
  employee: { select: employeeSummarySelect },
  logs: {
    orderBy: { activityTime: 'asc' as const },
    select: {
      id: true,
      activityType: true,
      activityTime: true,
      latitude: true,
      longitude: true,
      deviceInfo: true,
      createdAt: true,
    },
  },
} satisfies Prisma.AttendanceSelect;

export const attendanceDetailSelect = attendanceListSelect;

export type AttendanceListRecord = Prisma.AttendanceGetPayload<{
  select: typeof attendanceListSelect;
}>;

export type AttendanceDetailRecord = Prisma.AttendanceGetPayload<{
  select: typeof attendanceDetailSelect;
}>;
