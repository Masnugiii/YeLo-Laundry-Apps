import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import {
  BACKUP_SCHEDULES,
  BACKUP_SETTINGS_KEY,
  BackupSchedule,
  BackupSettings,
  DEFAULT_BACKUP_SETTINGS,
} from '../types/backup-settings.types';

@Injectable()
export class BackupSettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSettings(): Promise<BackupSettings> {
    const setting = await this.prisma.systemSetting.findUnique({
      where: { settingKey: BACKUP_SETTINGS_KEY },
      select: { settingValue: true },
    });

    if (!setting) {
      return { ...DEFAULT_BACKUP_SETTINGS };
    }

    return this.normalize(JSON.parse(setting.settingValue) as Partial<BackupSettings>);
  }

  async updateSettings(dto: Partial<BackupSettings>): Promise<BackupSettings> {
    const current = await this.getSettings();
    const next = this.normalize({ ...current, ...dto });

    await this.prisma.systemSetting.upsert({
      where: { settingKey: BACKUP_SETTINGS_KEY },
      create: {
        settingKey: BACKUP_SETTINGS_KEY,
        settingValue: JSON.stringify(next),
        description: 'Backup configuration',
      },
      update: { settingValue: JSON.stringify(next) },
    });

    return next;
  }

  private normalize(input: Partial<BackupSettings>): BackupSettings {
    const schedule = BACKUP_SCHEDULES.includes(input.schedule as BackupSchedule)
      ? (input.schedule as BackupSchedule)
      : DEFAULT_BACKUP_SETTINGS.schedule;

    return {
      enabled:
        typeof input.enabled === 'boolean'
          ? input.enabled
          : DEFAULT_BACKUP_SETTINGS.enabled,
      schedule,
      retentionDays:
        typeof input.retentionDays === 'number' && input.retentionDays > 0
          ? input.retentionDays
          : DEFAULT_BACKUP_SETTINGS.retentionDays,
    };
  }
}
