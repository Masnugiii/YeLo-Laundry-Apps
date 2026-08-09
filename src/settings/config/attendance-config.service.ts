import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import { AttendanceSettingsRepository } from '../../attendance/attendance-settings.repository';
import {
  AttendanceConfig,
  AttendanceGpsConfig,
  UpdateAttendanceConfigInput,
} from '../types/attendance-config.types';
import {
  formatTimeValue,
  parseTimeString,
} from '../utils/attendance-time.util';

function defaultAttendanceTimes() {
  return {
    workStartTime: parseTimeString('08:00'),
    workEndTime: parseTimeString('17:00'),
  };
}

@Injectable()
export class AttendanceConfigService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly attendanceSettingsRepository: AttendanceSettingsRepository,
  ) {}

  async getConfig(): Promise<AttendanceConfig> {
    const [attendanceSetting, gps, shiftCount] = await Promise.all([
      this.prisma.attendanceSetting.findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      }),
      this.attendanceSettingsRepository.getGpsConfig(),
      this.prisma.systemSetting.count({
        where: { settingKey: { startsWith: 'attendance.shift.' } },
      }),
    ]);

    if (!attendanceSetting) {
      const defaults = defaultAttendanceTimes();
      return {
        workStartTime: formatTimeValue(defaults.workStartTime),
        workEndTime: formatTimeValue(defaults.workEndTime),
        lateToleranceMinutes: 15,
        overtimeEnabled: false,
        gps,
        shiftCount,
      };
    }

    return {
      id: attendanceSetting.id,
      workStartTime: formatTimeValue(attendanceSetting.workStartTime),
      workEndTime: formatTimeValue(attendanceSetting.workEndTime),
      lateToleranceMinutes: attendanceSetting.lateToleranceMinutes,
      overtimeEnabled: attendanceSetting.overtimeEnabled,
      gps,
      shiftCount,
    };
  }

  async updateConfig(dto: UpdateAttendanceConfigInput): Promise<AttendanceConfig> {
    const existing = await this.prisma.attendanceSetting.findFirst({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    const defaults = defaultAttendanceTimes();
    const data = {
      workStartTime: dto.workStartTime
        ? parseTimeString(dto.workStartTime)
        : existing?.workStartTime ?? defaults.workStartTime,
      workEndTime: dto.workEndTime
        ? parseTimeString(dto.workEndTime)
        : existing?.workEndTime ?? defaults.workEndTime,
      lateToleranceMinutes:
        dto.lateToleranceMinutes ?? existing?.lateToleranceMinutes ?? 15,
      overtimeEnabled: dto.overtimeEnabled ?? existing?.overtimeEnabled ?? false,
      isActive: true,
    };

    if (existing) {
      await this.prisma.attendanceSetting.update({
        where: { id: existing.id },
        data,
      });
    } else {
      await this.prisma.attendanceSetting.create({ data });
    }

    if (dto.gps !== undefined) {
      if (dto.gps === null) {
        await this.attendanceSettingsRepository.clearGpsConfig();
      } else {
        const currentGps =
          (await this.attendanceSettingsRepository.getGpsConfig()) ?? {
            officeLatitude: 0,
            officeLongitude: 0,
            officeRadiusMeters: 100,
          };
        const nextGps: AttendanceGpsConfig = {
          officeLatitude: dto.gps.officeLatitude ?? currentGps.officeLatitude,
          officeLongitude:
            dto.gps.officeLongitude ?? currentGps.officeLongitude,
          officeRadiusMeters:
            dto.gps.officeRadiusMeters ?? currentGps.officeRadiusMeters,
        };
        await this.attendanceSettingsRepository.saveGpsConfig(nextGps);
      }
    }

    return this.getConfig();
  }
}
