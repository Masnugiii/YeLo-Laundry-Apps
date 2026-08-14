import {
  appendQueryParam,
  classifyPrismaConnectionError,
  databaseHostFingerprint,
  formatDatabaseUrlDiagnostics,
  hasQueryParam,
  inspectDatabaseUrl,
  resolvePrismaDatabaseUrl,
} from '../../src/database/prisma/prisma.service';

describe('appendQueryParam', () => {
  it('preserves existing query params and userinfo', () => {
    const input =
      'postgresql://postgres.abc:p%40ss%2Fword@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?schema=public';
    const resolved = appendQueryParam(input, 'pgbouncer', 'true');
    expect(resolved.startsWith(input)).toBe(true);
    expect(resolved).toContain('schema=public');
    expect(resolved).toContain('pgbouncer=true');
    expect(resolved).toContain('p%40ss%2Fword');
  });

  it('does not duplicate existing keys', () => {
    const input =
      'postgresql://u:p@host:5432/db?pgbouncer=true&schema=public';
    expect(appendQueryParam(input, 'pgbouncer', 'true')).toBe(input);
  });
});

describe('resolvePrismaDatabaseUrl', () => {
  it('adds sslmode=require for Supabase session pooler port 5432 without pgbouncer', () => {
    const input =
      'postgresql://user:pass@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?schema=public';
    const resolved = resolvePrismaDatabaseUrl(input)!;
    expect(resolved).toContain('schema=public');
    expect(resolved).toContain('sslmode=require');
    expect(resolved).not.toContain('pgbouncer=true');
    expect(hasQueryParam(resolved, 'schema')).toBe(true);
  });

  it('adds pgbouncer=true only for transaction pooler port 6543', () => {
    const input =
      'postgresql://user:pass@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres';
    const resolved = resolvePrismaDatabaseUrl(input)!;
    expect(resolved).toContain('pgbouncer=true');
    expect(resolved).toContain('sslmode=require');
  });

  it('does not rewrite password-bearing userinfo via URL serialization', () => {
    const input =
      'postgresql://postgres.ref:sec%40ret+weird@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres';
    const resolved = resolvePrismaDatabaseUrl(input)!;
    expect(resolved).toContain('postgres.ref:sec%40ret+weird@');
    expect(resolved).toContain('pgbouncer=true');
  });

  it('leaves non-pooler local URLs unchanged', () => {
    const input = 'postgresql://postgres:postgres@localhost:5432/yelo_laundry';
    expect(resolvePrismaDatabaseUrl(input)).toBe(input);
  });
});

describe('inspectDatabaseUrl', () => {
  it('exposes safe fields without password', () => {
    const diagnostics = inspectDatabaseUrl(
      'postgresql://postgres.abc:super-secret@db.example.com:5432/mydb?pgbouncer=true&sslmode=require',
    );
    expect(diagnostics).toMatchObject({
      present: true,
      parseable: true,
      username: 'postgres.abc',
      hostname: 'db.example.com',
      port: '5432',
      database: 'mydb',
      hasPgbouncer: true,
      hasSslmodeRequire: true,
      passwordPresent: true,
    });
    const formatted = formatDatabaseUrlDiagnostics(diagnostics);
    expect(formatted).toContain('username=postgres.abc');
    expect(formatted).not.toContain('super-secret');
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

describe('classifyPrismaConnectionError', () => {
  it('detects authentication failures', () => {
    expect(
      classifyPrismaConnectionError(
        new Error(
          'Authentication failed against database server, the provided database credentials for `postgres` are not valid.',
        ),
      ),
    ).toBe('auth_failed');
  });
});
