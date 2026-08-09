import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  buildHolidaySettingKey,
  HOLIDAY_SETTING_PREFIX,
  HolidayRecord,
  parseHolidayRecord,
} from './utils/holiday-meta.util';
import {
  buildLeaveSettingKey,
  isDateWithinLeave,
  LEAVE_SETTING_PREFIX,
  LeaveRecord,
  parseLeaveRecord,
} from './utils/leave-meta.util';
import {
  buildShiftSettingKey,
  parseShiftRecord,
  SHIFT_SETTING_PREFIX,
  ShiftRecord,
} from './utils/shift-meta.util';
import { formatDateKey } from './utils/attendance-date.util';

export interface GpsConfig {
  officeLatitude: number;
  officeLongitude: number;
  officeRadiusMeters: number;
}

const GPS_LATITUDE_KEY = 'attendance.gps.office_latitude';
const GPS_LONGITUDE_KEY = 'attendance.gps.office_longitude';
const GPS_RADIUS_KEY = 'attendance.gps.office_radius_meters';

@Injectable()
export class AttendanceSettingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private async upsertSetting(key: string, value: string, description?: string) {
    return this.prisma.systemSetting.upsert({
      where: { settingKey: key },
      create: { settingKey: key, settingValue: value, description },
      update: { settingValue: value, description },
    });
  }

  private async getSettingValue(key: string): Promise<string | null> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: key },
      select: { settingValue: true },
    });

    return setting?.settingValue ?? null;
  }

  async getGpsConfig(): Promise<GpsConfig | null> {
    const [lat, lon, radius] = await Promise.all([
      this.getSettingValue(GPS_LATITUDE_KEY),
      this.getSettingValue(GPS_LONGITUDE_KEY),
      this.getSettingValue(GPS_RADIUS_KEY),
    ]);

    if (!lat || !lon || !radius) {
      return null;
    }

    return {
      officeLatitude: Number.parseFloat(lat),
      officeLongitude: Number.parseFloat(lon),
      officeRadiusMeters: Number.parseFloat(radius),
    };
  }

  async saveShift(record: ShiftRecord) {
    await this.upsertSetting(
      buildShiftSettingKey(record.id),
      JSON.stringify(record),
      `Shift ${record.name}`,
    );

    return record;
  }

  async getShift(id: string): Promise<ShiftRecord | null> {
    const value = await this.getSettingValue(buildShiftSettingKey(id));

    return value ? parseShiftRecord(value) : null;
  }

  async listShifts(activeOnly = false): Promise<ShiftRecord[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: SHIFT_SETTING_PREFIX } },
      select: { settingValue: true },
      orderBy: { createdAt: 'asc' },
    });

    return settings
      .map((setting) => parseShiftRecord(setting.settingValue))
      .filter((record): record is ShiftRecord => record !== null)
      .filter((record) => (activeOnly ? record.isActive : true));
  }

  async deleteShift(id: string) {
    await this.prisma.systemSetting.deleteMany({
      where: { settingKey: buildShiftSettingKey(id) },
    });
  }

  async saveLeave(record: LeaveRecord) {
    await this.upsertSetting(
      buildLeaveSettingKey(record.id),
      JSON.stringify(record),
      `Leave ${record.id}`,
    );

    return record;
  }

  async getLeave(id: string): Promise<LeaveRecord | null> {
    const value = await this.getSettingValue(buildLeaveSettingKey(id));

    return value ? parseLeaveRecord(value) : null;
  }

  async listLeaves(filters?: {
    employeeId?: string;
    status?: LeaveRecord['status'];
    dateFrom?: string;
    dateTo?: string;
  }): Promise<LeaveRecord[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: LEAVE_SETTING_PREFIX } },
      select: { settingValue: true },
      orderBy: { createdAt: 'desc' },
    });

    return settings
      .map((setting) => parseLeaveRecord(setting.settingValue))
      .filter((record): record is LeaveRecord => record !== null)
      .filter((record) => {
        if (filters?.employeeId && record.employeeId !== filters.employeeId) {
          return false;
        }

        if (filters?.status && record.status !== filters.status) {
          return false;
        }

        if (filters?.dateFrom && record.endDate < filters.dateFrom) {
          return false;
        }

        if (filters?.dateTo && record.startDate > filters.dateTo) {
          return false;
        }

        return true;
      });
  }

  async getApprovedLeaveForDate(
    employeeId: string,
    date: Date,
  ): Promise<LeaveRecord | null> {
    const dateKey = formatDateKey(date);
    const leaves = await this.listLeaves({
      employeeId,
      status: 'APPROVED',
    });

    return (
      leaves.find((leave) => isDateWithinLeave(dateKey, leave)) ?? null
    );
  }

  async saveHoliday(record: HolidayRecord) {
    await this.upsertSetting(
      buildHolidaySettingKey(record.id),
      JSON.stringify(record),
      `Holiday ${record.name}`,
    );

    return record;
  }

  async getHoliday(id: string): Promise<HolidayRecord | null> {
    const value = await this.getSettingValue(buildHolidaySettingKey(id));

    return value ? parseHolidayRecord(value) : null;
  }

  async listHolidays(activeOnly = false): Promise<HolidayRecord[]> {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: HOLIDAY_SETTING_PREFIX } },
      select: { settingValue: true },
      orderBy: { createdAt: 'asc' },
    });

    return settings
      .map((setting) => parseHolidayRecord(setting.settingValue))
      .filter((record): record is HolidayRecord => record !== null)
      .filter((record) => (activeOnly ? record.isActive : true));
  }

  async getHolidayForDate(date: Date): Promise<HolidayRecord | null> {
    const dateKey = formatDateKey(date);
    const holidays = await this.listHolidays(true);

    return holidays.find((holiday) => holiday.date === dateKey) ?? null;
  }

  async deleteHoliday(id: string) {
    await this.prisma.systemSetting.deleteMany({
      where: { settingKey: buildHolidaySettingKey(id) },
    });
  }
}
