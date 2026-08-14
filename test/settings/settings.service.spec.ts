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
import { PaymentConfigService } from '../../src/settings/config/payment-config.service';
import { ConfigAuditService } from '../../src/settings/audit/config-audit.service';
import { SettingsService } from '../../src/settings/settings.service';
import { DEFAULT_BACKUP_SETTINGS } from '../../src/settings/types/backup-settings.types';
import { DEFAULT_DOCUMENT_RULES } from '../../src/settings/types/document-rules.types';
import { DEFAULT_NOTIFICATION_TOGGLE_SETTINGS } from '../../src/settings/types/notification-settings.types';
import { DEFAULT_CUSTOMER_PAYMENT_CONFIG } from '../../src/settings/types/payment-settings.types';

describe('SettingsService', () => {
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
  const paymentConfigService = {
    getConfig: jest.fn(),
    updateConfig: jest.fn(),
  };
  const receiptConfigService = {
    getConfig: jest.fn(),
    updateConfig: jest.fn(),
  };
  const numberingService = {
    updateConfiguration: jest.fn(),
  };
  const prisma = {
    service: { findMany: jest.fn() },
    servicePrice: { findMany: jest.fn() },
    paymentMethod: { findMany: jest.fn() },
    expenseCategory: { findMany: jest.fn() },
    notificationTemplate: { findMany: jest.fn() },
    queueSetting: { findFirst: jest.fn() },
    numberingSequence: { findMany: jest.fn() },
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
      paymentConfigService as unknown as PaymentConfigService,
      receiptConfigService as unknown as import('../../src/settings/config/receipt-config.service').ReceiptConfigService,
      numberingService as unknown as import('../../src/numbering/numbering.service').NumberingService,
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
    prisma.notificationTemplate.findMany.mockResolvedValue([]);
    prisma.queueSetting.findFirst.mockResolvedValue(null);
    prisma.numberingSequence.findMany.mockResolvedValue([]);
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
    paymentConfigService.getConfig.mockResolvedValue(DEFAULT_CUSTOMER_PAYMENT_CONFIG);
  }

  it('returns unified settings manifest', async () => {
    mockManifestBasics();

    const manifest = await service.getManifest();

    expect(manifest.writableSections).toContain('company');
    expect(manifest.sections.company).toEqual({ companyName: 'Yelo Laundry' });
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

    expect(adminSettingsService.updateCompanySettings).toHaveBeenCalledWith({
      companyName: 'After',
    });
    expect(configAuditService.logConfigUpdated).toHaveBeenCalledWith({
      employeeId: 'owner-id',
      section: 'company',
      before,
      after,
    });
    expect(result.section).toBe('company');
  });

  it('rejects invalid company configuration with 400', async () => {
    adminSettingsService.getCompanySettings.mockResolvedValue({
      companyName: 'Yelo',
    });

    await expect(
      service.updateSection('company', { taxRate: 'invalid' }, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(configAuditService.logConfigUpdated).not.toHaveBeenCalled();
  });

  it('rejects PATCH on read-only section', async () => {
    await expect(
      service.updateSection('services', {}, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('throws NotFoundException for unknown section', async () => {
    await expect(service.getSection('unknown')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('delegates payroll update with skipAudit and audits via ConfigAuditService', async () => {
    payrollService.getSettings.mockResolvedValue(DEFAULT_PAYROLL_SETTINGS);
    payrollService.updateSettings.mockResolvedValue({
      ...DEFAULT_PAYROLL_SETTINGS,
      laundryKgRate: 1500,
    });

    await service.updateSection(
      'payroll',
      { laundryKgRate: 1500 },
      'owner-id',
    );

    expect(payrollService.updateSettings).toHaveBeenCalledWith(
      { laundryKgRate: 1500 },
      'owner-id',
      { skipAudit: true },
    );
    expect(configAuditService.logConfigUpdated).toHaveBeenCalled();
  });
});
