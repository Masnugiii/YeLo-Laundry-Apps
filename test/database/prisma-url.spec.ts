import {
  databaseHostFingerprint,
  resolvePrismaDatabaseUrl,
} from '../../src/database/prisma/prisma.service';

describe('resolvePrismaDatabaseUrl', () => {
  it('adds pgbouncer=true for Supabase pooler hosts', () => {
    const input =
      'postgresql://user:pass@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres';
    const resolved = resolvePrismaDatabaseUrl(input);
    expect(resolved).toContain('pgbouncer=true');
    expect(resolved).toContain('sslmode=require');
    expect(resolved).toContain('pooler.supabase.com');
  });

  it('does not duplicate pgbouncer when already set', () => {
    const input =
      'postgresql://user:pass@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true';
    const resolved = resolvePrismaDatabaseUrl(input)!;
    expect(resolved.match(/pgbouncer=true/g)?.length).toBe(1);
  });

  it('leaves non-pooler URLs unchanged aside from normalization', () => {
    const input = 'postgresql://postgres:postgres@localhost:5432/yelo_laundry';
    const resolved = resolvePrismaDatabaseUrl(input);
    expect(resolved).toBe(input);
  });
});

describe('databaseHostFingerprint', () => {
  it('returns host/db without credentials', () => {
    const fp = databaseHostFingerprint(
      'postgresql://user:super-secret@db.example.com:5432/mydb',
    );
    expect(fp).toBe('db.example.com:5432/mydb');
    expect(fp).not.toContain('super-secret');
    expect(fp).not.toContain('user');
  });
});
