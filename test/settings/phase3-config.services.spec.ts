import { DocumentRulesService } from '../../src/settings/config/document-rules.service';
import { BackupSettingsService } from '../../src/settings/config/backup-settings.service';
import { NotificationConfigService } from '../../src/settings/config/notification-config.service';
import { DEFAULT_DOCUMENT_RULES } from '../../src/settings/types/document-rules.types';
import { DEFAULT_BACKUP_SETTINGS } from '../../src/settings/types/backup-settings.types';
import {
  assertValidDocumentUpload,
  validateDocumentUpload,
} from '../../src/settings/utils/document-rules-validation.util';
import { BadRequestException } from '@nestjs/common';

describe('DocumentRulesService', () => {
  const prisma = {
    systemSetting: {
      findUnique: jest.fn(),
      upsert: jest.fn(),
    },
  };

  let service: DocumentRulesService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new DocumentRulesService(prisma as never);
  });

  it('returns defaults when setting is absent', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue(null);

    const rules = await service.getRules();

    expect(rules).toEqual(DEFAULT_DOCUMENT_RULES);
    expect(rules.maxFileSizeBytes).toBe(10 * 1024 * 1024);
  });

  it('persists updated rules', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue(null);
    prisma.systemSetting.upsert.mockResolvedValue({});

    const updated = await service.updateRules({ ocrEnabled: true });

    expect(updated.ocrEnabled).toBe(true);
    expect(prisma.systemSetting.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { settingKey: 'documents.rules' },
      }),
    );
  });
});

describe('BackupSettingsService', () => {
  const prisma = {
    systemSetting: {
      findUnique: jest.fn(),
      upsert: jest.fn(),
    },
  };

  let service: BackupSettingsService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new BackupSettingsService(prisma as never);
  });

  it('returns defaults when setting is absent', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue(null);

    const settings = await service.getSettings();

    expect(settings).toEqual(DEFAULT_BACKUP_SETTINGS);
  });
});

describe('NotificationConfigService', () => {
  const prisma = {
    systemSetting: {
      findUnique: jest.fn(),
      upsert: jest.fn(),
    },
    notificationTemplate: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    },
  };

  let service: NotificationConfigService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new NotificationConfigService(prisma as never);
  });

  it('returns toggle defaults when setting is absent', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue(null);
    prisma.notificationTemplate.findMany.mockResolvedValue([]);

    const config = await service.getConfig();

    expect(config.settings.notify_new_order).toBe(true);
    expect(config.templates).toEqual([]);
  });

  it('disables mapped notification events when toggle is off', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue({
      settingValue: JSON.stringify({ notify_new_order: false }),
    });

    const enabled = await service.isTemplateCodeEnabled('order.created');

    expect(enabled).toBe(false);
  });

  it('allows unmapped notification events', async () => {
    prisma.systemSetting.findUnique.mockResolvedValue({
      settingValue: JSON.stringify({ notify_new_order: false }),
    });

    const enabled = await service.isTemplateCodeEnabled('attendance.late');

    expect(enabled).toBe(true);
  });
});

describe('document-rules-validation.util', () => {
  it('accepts valid uploads', () => {
    const result = validateDocumentUpload(DEFAULT_DOCUMENT_RULES, {
      mimeType: 'image/jpeg',
      fileSizeBytes: 1024,
    });

    expect(result.valid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('rejects oversized files using 10 MB limit', () => {
    const result = validateDocumentUpload(DEFAULT_DOCUMENT_RULES, {
      mimeType: 'image/jpeg',
      fileSizeBytes: 11 * 1024 * 1024,
    });

    expect(result.valid).toBe(false);
    expect(result.errors[0]).toContain('10485760');
  });

  it('throws BadRequestException via assertValidDocumentUpload', () => {
    expect(() =>
      assertValidDocumentUpload(DEFAULT_DOCUMENT_RULES, {
        mimeType: 'application/zip',
        fileSizeBytes: 100,
      }),
    ).toThrow(BadRequestException);
  });
});
