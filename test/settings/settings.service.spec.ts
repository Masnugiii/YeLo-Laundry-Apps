import {
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { AdminSettingsService } from '../../src/admin/admin-settings.service';
import { LoyaltySettingsService } from '../../src/loyalty/loyalty-settings.service';
import { DEFAULT_LOYALTY_SETTINGS } from '../../src/loyalty/loyalty.types';
import { PayrollService } from '../../src/payroll/payroll.service';
import { DEFAULT_PAYROLL_SETTINGS } from '../../src/payroll/payroll.types';
import { ConfigAuditService } from '../../src/settings/audit/config-audit.service';
import { SettingsService } from '../../src/settings/settings.service';

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
  const prisma = {
    service: { findMany: jest.fn() },
    servicePrice: { findMany: jest.fn() },
    attendanceSetting: { findFirst: jest.fn() },
    systemSetting: { findMany: jest.fn() },
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
    );
  });

  it('returns unified settings manifest', async () => {
    adminSettingsService.getCompanySettings.mockResolvedValue({
      companyName: 'Yelo Laundry',
    });
    payrollService.getSettings.mockResolvedValue(DEFAULT_PAYROLL_SETTINGS);
    loyaltySettingsService.getSettings.mockResolvedValue(
      DEFAULT_LOYALTY_SETTINGS,
    );
    prisma.service.findMany.mockResolvedValue([]);
    prisma.servicePrice.findMany.mockResolvedValue([]);
    prisma.attendanceSetting.findFirst.mockResolvedValue(null);
    prisma.systemSetting.findMany.mockResolvedValue([]);
    prisma.paymentMethod.findMany.mockResolvedValue([]);
    prisma.expenseCategory.findMany.mockResolvedValue([]);
    prisma.notificationTemplate.findMany.mockResolvedValue([]);
    prisma.queueSetting.findFirst.mockResolvedValue(null);
    prisma.numberingSequence.findMany.mockResolvedValue([]);

    const manifest = await service.getManifest();

    expect(manifest.writableSections).toEqual(['company', 'payroll', 'loyalty']);
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
