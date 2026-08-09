import { AuditLogService } from '../../src/admin/audit-log.service';
import { ConfigAuditService } from '../../src/settings/audit/config-audit.service';

describe('ConfigAuditService', () => {
  it('records config_updated audit entries with sanitized metadata', async () => {
    const record = jest.fn().mockResolvedValue(undefined);
    const auditLogService = { record } as unknown as AuditLogService;
    const service = new ConfigAuditService(auditLogService);

    await service.logConfigUpdated({
      employeeId: 'owner-id',
      section: 'company',
      before: { companyName: 'Before', apiToken: 'secret' },
      after: { companyName: 'After', apiToken: 'new-secret' },
    });

    expect(record).toHaveBeenCalledWith(
      expect.objectContaining({
        employeeId: 'owner-id',
        module: 'settings',
        action: 'config_updated',
        referenceId: 'company',
      }),
    );

    const payload = JSON.parse(record.mock.calls[0][0].description);
    expect(payload.section).toBe('company');
    expect(payload.before.apiToken).toBe('[REDACTED]');
    expect(payload.after.apiToken).toBe('[REDACTED]');
  });

  it('redacts password, token, secret, credential, and apiKey fields', async () => {
    const record = jest.fn().mockResolvedValue(undefined);
    const auditLogService = { record } as unknown as AuditLogService;
    const service = new ConfigAuditService(auditLogService);

    await service.logConfigUpdated({
      employeeId: 'owner-id',
      section: 'payroll',
      before: {
        password: 'old-pass',
        refreshToken: 'old-token',
        clientSecret: 'old-secret',
        credential: 'old-credential',
        apiKey: 'old-key',
      },
      after: {
        password: 'new-pass',
        refreshToken: 'new-token',
        clientSecret: 'new-secret',
        credential: 'new-credential',
        apiKey: 'new-key',
      },
    });

    const payload = JSON.parse(record.mock.calls[0][0].description);
    expect(payload.before).toEqual({
      password: '[REDACTED]',
      refreshToken: '[REDACTED]',
      clientSecret: '[REDACTED]',
      credential: '[REDACTED]',
      apiKey: '[REDACTED]',
    });
    expect(payload.after).toEqual({
      password: '[REDACTED]',
      refreshToken: '[REDACTED]',
      clientSecret: '[REDACTED]',
      credential: '[REDACTED]',
      apiKey: '[REDACTED]',
    });
  });
});
