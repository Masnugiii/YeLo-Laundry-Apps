export interface HolidayRecord {
  id: string;
  name: string;
  date: string;
  description?: string;
  isActive: boolean;
  createdByEmployeeId: string;
  updatedByEmployeeId?: string;
  createdAt: string;
  updatedAt: string;
}

export const HOLIDAY_SETTING_PREFIX = 'attendance.holiday.';

export function buildHolidaySettingKey(id: string): string {
  return `${HOLIDAY_SETTING_PREFIX}${id}`;
}

export function parseHolidayRecord(value: string): HolidayRecord | null {
  try {
    return JSON.parse(value) as HolidayRecord;
  } catch {
    return null;
  }
}
