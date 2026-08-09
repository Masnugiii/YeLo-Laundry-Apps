export interface ShiftRecord {
  id: string;
  name: string;
  startTime: string;
  endTime: string;
  toleranceMinutes: number;
  breakDurationMinutes: number;
  isActive: boolean;
  createdByEmployeeId: string;
  updatedByEmployeeId?: string;
  createdAt: string;
  updatedAt: string;
}

export const SHIFT_SETTING_PREFIX = 'attendance.shift.';

export function buildShiftSettingKey(id: string): string {
  return `${SHIFT_SETTING_PREFIX}${id}`;
}

export function parseShiftRecord(value: string): ShiftRecord | null {
  try {
    return JSON.parse(value) as ShiftRecord;
  } catch {
    return null;
  }
}

export function parseTimeToMinutes(time: string): number {
  const [hours, minutes] = time.split(':').map((part) => Number.parseInt(part, 10));

  return hours * 60 + minutes;
}

export function minutesToTimeString(totalMinutes: number): string {
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}
