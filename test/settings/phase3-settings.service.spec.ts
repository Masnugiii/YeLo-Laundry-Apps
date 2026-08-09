import {
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { AdminSettingsService } from '../../src/admin/admin-settings.service';
import { LoyaltySettingsService } from '../../src/loyalty/loyalty-settings.service';
import { DEFAULT_LOYALTY_SETTINGS } from '../../src/loyalty/loyalty.types';
import { PayrollService } from '../../src/payroll/payroll.service';
import { DEFAULT_PAYROLL_SETTINGS } from '../../src/payroll/payroll.types';
import { AttendanceConfigService } from '../../src/settings/config/attendance-config.service';
import { BackupSettingsService } from '../../src/settings/config/backup-settings.service';
import { DocumentRulesService } from '../../src/settings/config/document-rules.service';
import { NotificationConfigService } from '../../src/settings/config/notification-config.service';
import { ConfigAuditService } from '../../src/settings/audit/config-audit.service';
import { SettingsService } from '../../src/settings/settings.service';
import { DEFAULT_BACKUP_SETTINGS } from '../../src/settings/types/backup-settings.types';
import { DEFAULT_DOCUMENT_RULES } from '../../src/settings/types/document-rules.types';
import { DEFAULT_NOTIFICATION_TOGGLE_SETTINGS } from '../../src/settings/types/notification-settings.types';

describe('SettingsService Phase 3B', () => {
  const adminSettingsService = {
    getCompanySettings: jest.fn(),
    updateCompanySettings: jest.fn(),
  };
  const payrollService = {
    getSettings: jest.fn(),
    updateSettings: jest.fn(),
  };
  const loyaltySettingsService = {
    getSettings: jest.fn(),
    updateSettings: jest.fn(),
  };
  const configAuditService = {
    logConfigUpdated: jest.fn(),
  };
  const attendanceConfigService = {
    getConfig: jest.fn(),
    updateConfig: jest.fn(),
  };
  const documentRulesService = {
    getRules: jest.fn(),
    updateRules: jest.fn(),
  };
  const backupSettingsService = {
    getSettings: jest.fn(),
    updateSettings: jest.fn(),
  };
  const notificationConfigService = {
    getConfig: jest.fn(),
    updateConfig: jest.fn(),
  };
  const prisma = {
    service: { findMany: jest.fn() },
    servicePrice: { findMany: jest.fn() },
    paymentMethod: { findMany: jest.fn() },
    expenseCategory: { findMany: jest.fn() },
    numberingSequence: { findMany: jest.fn() },
    queueSetting: { findFirst: jest.fn() },
  };

  let service: SettingsService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SettingsService(
      prisma as never,
      adminSettingsService as unknown as AdminSettingsService,
      payrollService as unknown as PayrollService,
      loyaltySettingsService as unknown as LoyaltySettingsService,
      configAuditService as unknown as ConfigAuditService,
      attendanceConfigService as unknown as AttendanceConfigService,
      documentRulesService as unknown as DocumentRulesService,
      backupSettingsService as unknown as BackupSettingsService,
      notificationConfigService as unknown as NotificationConfigService,
    );
  });

  function mockManifestBasics() {
    adminSettingsService.getCompanySettings.mockResolvedValue({
      companyName: 'Yelo Laundry',
    });
    payrollService.getSettings.mockResolvedValue(DEFAULT_PAYROLL_SETTINGS);
    loyaltySettingsService.getSettings.mockResolvedValue(
      DEFAULT_LOYALTY_SETTINGS,
    );
    prisma.service.findMany.mockResolvedValue([]);
    prisma.servicePrice.findMany.mockResolvedValue([]);
    prisma.paymentMethod.findMany.mockResolvedValue([]);
    prisma.expenseCategory.findMany.mockResolvedValue([]);
    prisma.numberingSequence.findMany.mockResolvedValue([]);
    prisma.queueSetting.findFirst.mockResolvedValue(null);
    attendanceConfigService.getConfig.mockResolvedValue({
      workStartTime: '08:00',
      workEndTime: '17:00',
      lateToleranceMinutes: 15,
      overtimeEnabled: false,
      gps: null,
      shiftCount: 0,
    });
    notificationConfigService.getConfig.mockResolvedValue({
      settings: DEFAULT_NOTIFICATION_TOGGLE_SETTINGS,
      templates: [],
    });
    backupSettingsService.getSettings.mockResolvedValue(DEFAULT_BACKUP_SETTINGS);
    documentRulesService.getRules.mockResolvedValue(DEFAULT_DOCUMENT_RULES);
  }

  it('returns unified settings manifest with Phase 3 writable sections', async () => {
    mockManifestBasics();

    const manifest = await service.getManifest();

    expect(manifest.writableSections).toEqual([
      'company',
      'payroll',
      'loyalty',
      'attendance',
      'notifications',
      'documents',
      'backup',
    ]);
  });

  it('reads company section', async () => {
    adminSettingsService.getCompanySettings.mockResolvedValue({
      companyName: 'Yelo Laundry',
      timezone: 'Asia/Jakarta',
    });

    const data = await service.getSection('company');

    expect(data).toEqual({
      companyName: 'Yelo Laundry',
      timezone: 'Asia/Jakarta',
    });
  });

  it('updates company section and writes config audit log', async () => {
    const before = { companyName: 'Before' };
    const after = { companyName: 'After' };

    adminSettingsService.getCompanySettings
      .mockResolvedValueOnce(before)
      .mockResolvedValueOnce(after);
    adminSettingsService.updateCompanySettings.mockResolvedValue(after);

    const result = await service.updateSection(
      'company',
      { companyName: 'After' },
      'owner-id',
    );

    expect(configAuditService.logConfigUpdated).toHaveBeenCalledWith({
      employeeId: 'owner-id',
      section: 'company',
      before,
      after,
    });
    expect(result.section).toBe('company');
  });

  it('reads and updates attendance section', async () => {
    const before = {
      workStartTime: '08:00',
      workEndTime: '17:00',
      lateToleranceMinutes: 15,
      overtimeEnabled: false,
      gps: null,
      shiftCount: 1,
    };
    const after = { ...before, lateToleranceMinutes: 20 };

    attendanceConfigService.getConfig
      .mockResolvedValueOnce(before)
      .mockResolvedValueOnce(after);
    attendanceConfigService.updateConfig.mockResolvedValue(after);

    const result = await service.updateSection(
      'attendance',
      { lateToleranceMinutes: 20 },
      'owner-id',
    );

    expect(attendanceConfigService.updateConfig).toHaveBeenCalledWith({
      lateToleranceMinutes: 20,
    });
    expect(configAuditService.logConfigUpdated).toHaveBeenCalled();
    expect(result.data).toEqual(after);
  });

  it('reads and updates documents section', async () => {
    const before = { ...DEFAULT_DOCUMENT_RULES };
    const after = { ...DEFAULT_DOCUMENT_RULES, ocrEnabled: true };

    documentRulesService.getRules
      .mockResolvedValueOnce(before)
      .mockResolvedValueOnce(after);
    documentRulesService.updateRules.mockResolvedValue(after);

    await service.updateSection('documents', { ocrEnabled: true }, 'owner-id');

    expect(documentRulesService.updateRules).toHaveBeenCalledWith({
      ocrEnabled: true,
    });
    expect(configAuditService.logConfigUpdated).toHaveBeenCalled();
  });

  it('reads and updates backup section', async () => {
    const before = { ...DEFAULT_BACKUP_SETTINGS };
    const after = { ...DEFAULT_BACKUP_SETTINGS, enabled: true };

    backupSettingsService.getSettings
      .mockResolvedValueOnce(before)
      .mockResolvedValueOnce(after);
    backupSettingsService.updateSettings.mockResolvedValue(after);

    await service.updateSection('backup', { enabled: true }, 'owner-id');

    expect(backupSettingsService.updateSettings).toHaveBeenCalledWith({
      enabled: true,
    });
    expect(configAuditService.logConfigUpdated).toHaveBeenCalled();
  });

  it('reads and updates notifications section', async () => {
    const before = {
      settings: DEFAULT_NOTIFICATION_TOGGLE_SETTINGS,
      templates: [],
    };
    const after = {
      settings: { ...DEFAULT_NOTIFICATION_TOGGLE_SETTINGS, notify_wallet: false },
      templates: [],
    };

    notificationConfigService.getConfig
      .mockResolvedValueOnce(before)
      .mockResolvedValueOnce(after);
    notificationConfigService.updateConfig.mockResolvedValue(after);

    await service.updateSection(
      'notifications',
      { settings: { notify_wallet: false } },
      'owner-id',
    );

    expect(notificationConfigService.updateConfig).toHaveBeenCalledWith({
      settings: { notify_wallet: false },
    });
    expect(configAuditService.logConfigUpdated).toHaveBeenCalled();
  });

  it('returns honest not_configured delivery section', async () => {
    const data = await service.getSection('delivery');

    expect(data).toEqual({
      status: 'not_configured',
      message: 'No delivery configuration model exists in the current schema',
    });
  });

  it('rejects PATCH on delivery section', async () => {
    await expect(
      service.updateSection('delivery', {}, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects invalid document configuration with 400', async () => {
    documentRulesService.getRules.mockResolvedValue(DEFAULT_DOCUMENT_RULES);

    await expect(
      service.updateSection(
        'documents',
        { maxFileSizeBytes: 'invalid' },
        'owner-id',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(configAuditService.logConfigUpdated).not.toHaveBeenCalled();
  });

  it('rejects invalid backup configuration with 400', async () => {
    backupSettingsService.getSettings.mockResolvedValue(DEFAULT_BACKUP_SETTINGS);

    await expect(
      service.updateSection('backup', { schedule: 'hourly' }, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects invalid attendance configuration with 400', async () => {
    attendanceConfigService.getConfig.mockResolvedValue({
      workStartTime: '08:00',
      workEndTime: '17:00',
      lateToleranceMinutes: 15,
      overtimeEnabled: false,
      gps: null,
      shiftCount: 0,
    });

    await expect(
      service.updateSection('attendance', { workStartTime: '25:99' }, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('throws NotFoundException for unknown section', async () => {
    await expect(service.getSection('unknown')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
