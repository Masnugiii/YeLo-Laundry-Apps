export const BACKUP_SETTINGS_KEY = 'backup.settings';

export const BACKUP_SCHEDULES = ['daily', 'weekly', 'monthly'] as const;
export type BackupSchedule = (typeof BACKUP_SCHEDULES)[number];

export interface BackupSettings {
  enabled: boolean;
  schedule: BackupSchedule;
  retentionDays: number;
}

export const DEFAULT_BACKUP_SETTINGS: BackupSettings = {
  enabled: false,
  schedule: 'daily',
  retentionDays: 30,
};
