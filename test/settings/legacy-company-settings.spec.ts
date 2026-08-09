import { SettingsService } from '../../src/settings/settings.service';

describe('Legacy admin company settings PATCH', () => {
  it('delegates to unified SettingsService.updateSection for audit coverage', async () => {
    const settingsService = {
      getSection: jest.fn().mockResolvedValue({ companyName: 'Yelo Laundry' }),
      updateSection: jest.fn().mockResolvedValue({
        section: 'company',
        data: { companyName: 'Updated' },
      }),
    };

    const { AdminController } = await import('../../src/admin/admin.controller');
    const controller = new AdminController(
      { getDashboard: jest.fn() } as never,
      { findAll: jest.fn() } as never,
      settingsService as unknown as SettingsService,
    );

    const response = await controller.updateSettings(
      { companyName: 'Updated' },
      {
        employeeId: 'owner-id',
        phone: '081234567890',
        roles: ['OWNER'],
        permissions: ['settings'],
      },
    );

    expect(settingsService.updateSection).toHaveBeenCalledWith(
      'company',
      { companyName: 'Updated' },
      'owner-id',
    );
    expect(response.data).toEqual({ companyName: 'Updated' });
  });
});
