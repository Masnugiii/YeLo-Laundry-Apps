import { Prisma } from '@prisma/client';

const SEED_DEFAULT_DOCUMENT_RULES = {
  maxFileSizeBytes: 10 * 1024 * 1024,
  allowedMimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
  compressionMode: 'original',
  ocrEnabled: false,
} as const;

const SEED_DEFAULT_BACKUP_SETTINGS = {
  enabled: false,
  schedule: 'daily',
  retentionDays: 30,
} as const;

const SEED_DEFAULT_NOTIFICATION_SETTINGS = {
  notify_new_order: true,
  notify_payment: true,
  notify_ironing_finished: true,
  notify_pickup_delivery: true,
  notify_wallet: true,
} as const;

/** Default unit prices (IDR) keyed by service code. */
export const DEFAULT_SERVICE_PRICES: Record<string, number> = {
  CKS: 7000,
  CK: 7000,
  SETRIKA: 5000,
  KARPET: 25000,
  BONEKA: 20000,
  SEPATU: 45000,
  BED_COVER: 35000,
  JAKET: 25000,
};

export function buildDefaultAttendanceTimes() {
  const workStartTime = new Date('1970-01-01T08:00:00.000Z');
  const workEndTime = new Date('1970-01-01T17:00:00.000Z');
  return { workStartTime, workEndTime };
}

export async function seedDefaultServicePrices(
  tx: Prisma.TransactionClient,
  serviceCodes: readonly string[],
): Promise<number> {
  let created = 0;
  const effectiveDate = new Date();
  effectiveDate.setHours(0, 0, 0, 0);

  for (const serviceCode of serviceCodes) {
    const service = await tx.service.findFirst({
      where: {
        serviceCode,
        isActive: true,
        deletedAt: null,
      },
      select: { id: true },
    });

    if (!service) {
      continue;
    }

    const existingActivePrice = await tx.servicePrice.findFirst({
      where: {
        serviceId: service.id,
        isActive: true,
        deletedAt: null,
      },
      select: { id: true },
    });

    if (existingActivePrice) {
      continue;
    }

    await tx.servicePrice.create({
      data: {
        serviceId: service.id,
        price: DEFAULT_SERVICE_PRICES[serviceCode] ?? 10000,
        effectiveDate,
        isActive: true,
      },
    });

    created += 1;
  }

  return created;
}

export async function seedDefaultAttendanceSetting(
  tx: Prisma.TransactionClient,
): Promise<'created' | 'existing'> {
  const existing = await tx.attendanceSetting.findFirst({
    where: { isActive: true },
    select: { id: true },
  });

  if (existing) {
    return 'existing';
  }

  const { workStartTime, workEndTime } = buildDefaultAttendanceTimes();

  await tx.attendanceSetting.create({
    data: {
      workStartTime,
      workEndTime,
      lateToleranceMinutes: 15,
      overtimeEnabled: false,
      isActive: true,
    },
  });

  return 'created';
}

const ADMIN_TIMEZONE_KEY = 'admin.timezone';
const ADMIN_CURRENCY_KEY = 'admin.currency';

export async function seedSystemSettingIfAbsent(
  tx: Prisma.TransactionClient,
  key: string,
  value: string,
  description: string,
): Promise<'created' | 'existing'> {
  const existing = await tx.systemSetting.findUnique({
    where: { settingKey: key },
    select: { id: true },
  });

  if (existing) {
    return 'existing';
  }

  await tx.systemSetting.create({
    data: {
      settingKey: key,
      settingValue: value,
      description,
    },
  });

  return 'created';
}

export async function seedDefaultPhase3Settings(
  tx: Prisma.TransactionClient,
): Promise<{
  documents: 'created' | 'existing';
  backup: 'created' | 'existing';
  notifications: 'created' | 'existing';
  timezone: 'created' | 'existing';
  currency: 'created' | 'existing';
}> {
  const [documents, backup, notifications, timezone, currency] =
    await Promise.all([
      seedSystemSettingIfAbsent(
        tx,
        'documents.rules',
        JSON.stringify(SEED_DEFAULT_DOCUMENT_RULES),
        'Document upload rules',
      ),
      seedSystemSettingIfAbsent(
        tx,
        'backup.settings',
        JSON.stringify(SEED_DEFAULT_BACKUP_SETTINGS),
        'Backup configuration',
      ),
      seedSystemSettingIfAbsent(
        tx,
        'notification.settings',
        JSON.stringify(SEED_DEFAULT_NOTIFICATION_SETTINGS),
        'Notification outlet toggles',
      ),
      seedSystemSettingIfAbsent(
        tx,
        ADMIN_TIMEZONE_KEY,
        'Asia/Jakarta',
        'Company timezone',
      ),
      seedSystemSettingIfAbsent(
        tx,
        ADMIN_CURRENCY_KEY,
        'IDR',
        'Company currency',
      ),
    ]);

  return { documents, backup, notifications, timezone, currency };
}
