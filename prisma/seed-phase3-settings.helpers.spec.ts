import {
  seedDefaultPhase3Settings,
  seedSystemSettingIfAbsent,
} from './seed-settings.helpers';

describe('seedDefaultPhase3Settings', () => {
  const store = new Map<string, { settingValue: string; description: string }>();

  const tx = {
    systemSetting: {
      findUnique: jest.fn(async ({ where }: { where: { settingKey: string } }) => {
        const record = store.get(where.settingKey);
        return record ? { id: where.settingKey } : null;
      }),
      create: jest.fn(
        async ({
          data,
        }: {
          data: {
            settingKey: string;
            settingValue: string;
            description: string;
          };
        }) => {
          store.set(data.settingKey, {
            settingValue: data.settingValue,
            description: data.description,
          });
        },
      ),
    },
  };

  beforeEach(() => {
    store.clear();
    jest.clearAllMocks();
  });

  it('creates default Phase 3 settings when absent', async () => {
    const result = await seedDefaultPhase3Settings(tx as never);

    expect(result.documents).toBe('created');
    expect(result.backup).toBe('created');
    expect(result.notifications).toBe('created');
    expect(result.timezone).toBe('created');
    expect(result.currency).toBe('created');
    expect(store.has('documents.rules')).toBe(true);
    expect(JSON.parse(store.get('documents.rules')!.settingValue).maxFileSizeBytes).toBe(
      10 * 1024 * 1024,
    );
  });

  it('is idempotent and preserves existing values', async () => {
    store.set('documents.rules', {
      settingValue: JSON.stringify({
        maxFileSizeBytes: 999,
        allowedMimeTypes: ['image/jpeg'],
        compressionMode: 'original',
        ocrEnabled: true,
      }),
      description: 'custom',
    });

    const firstRun = await seedDefaultPhase3Settings(tx as never);
    const secondRun = await seedDefaultPhase3Settings(tx as never);

    expect(firstRun.documents).toBe('existing');
    expect(secondRun.documents).toBe('existing');
    expect(JSON.parse(store.get('documents.rules')!.settingValue).maxFileSizeBytes).toBe(
      999,
    );
    expect(tx.systemSetting.create).toHaveBeenCalledTimes(4);
  });

  it('creates only absent keys via seedSystemSettingIfAbsent', async () => {
    store.set('admin.timezone', {
      settingValue: 'Asia/Makassar',
      description: 'existing',
    });

    const timezone = await seedSystemSettingIfAbsent(
      tx as never,
      'admin.timezone',
      'Asia/Jakarta',
      'Company timezone',
    );
    const currency = await seedSystemSettingIfAbsent(
      tx as never,
      'admin.currency',
      'IDR',
      'Company currency',
    );

    expect(timezone).toBe('existing');
    expect(currency).toBe('created');
    expect(store.get('admin.timezone')!.settingValue).toBe('Asia/Makassar');
    expect(store.get('admin.currency')!.settingValue).toBe('IDR');
  });
});
