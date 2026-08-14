import { resolveCorsOrigins } from '../../src/config/configuration';

describe('resolveCorsOrigins', () => {
  it('always includes the production Vercel Admin origin', () => {
    const origins = resolveCorsOrigins(
      'http://localhost:3000,http://localhost:3001',
    );

    expect(origins).toContain('https://ye-lo-laundry-apps.vercel.app');
    expect(origins).toContain('http://localhost:3000');
    expect(origins).toContain('http://localhost:3001');
  });

  it('uses local defaults when CORS_ORIGINS is empty, plus Vercel', () => {
    const origins = resolveCorsOrigins('');

    expect(origins).toEqual(
      expect.arrayContaining([
        'https://ye-lo-laundry-apps.vercel.app',
        'http://localhost:3000',
        'http://localhost:3001',
        'http://localhost:5173',
      ]),
    );
  });

  it('deduplicates origins', () => {
    const origins = resolveCorsOrigins(
      'https://ye-lo-laundry-apps.vercel.app, https://ye-lo-laundry-apps.vercel.app',
    );

    expect(
      origins.filter((o) => o === 'https://ye-lo-laundry-apps.vercel.app'),
    ).toHaveLength(1);
  });
});
