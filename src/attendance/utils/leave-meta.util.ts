export type LeaveType =
  | 'ANNUAL'
  | 'SICK'
  | 'EMERGENCY'
  | 'MATERNITY'
  | 'UNPAID';

export type LeaveStatus = 'PENDING' | 'APPROVED' | 'REJECTED';

export interface LeaveRecord {
  id: string;
  employeeId: string;
  leaveType: LeaveType;
  startDate: string;
  endDate: string;
  reason: string;
  status: LeaveStatus;
  createdByEmployeeId: string;
  updatedByEmployeeId?: string;
  approvedByEmployeeId?: string;
  rejectedByEmployeeId?: string;
  rejectionReason?: string;
  createdAt: string;
  updatedAt: string;
}

export const LEAVE_SETTING_PREFIX = 'attendance.leave.';

export function buildLeaveSettingKey(id: string): string {
  return `${LEAVE_SETTING_PREFIX}${id}`;
}

export function parseLeaveRecord(value: string): LeaveRecord | null {
  try {
    return JSON.parse(value) as LeaveRecord;
  } catch {
    return null;
  }
}

export function isDateWithinLeave(date: string, leave: LeaveRecord): boolean {
  return date >= leave.startDate && date <= leave.endDate;
}
