import { SettingsController } from '../../src/settings/settings.controller';
import { SettingsService } from '../../src/settings/settings.service';

describe('SettingsController', () => {
  const settingsService = {
    getManifest: jest.fn(),
    getSection: jest.fn(),
    updateSection: jest.fn(),
  };

  let controller: SettingsController;

  beforeEach(() => {
    jest.clearAllMocks();
    controller = new SettingsController(
      settingsService as unknown as SettingsService,
    );
  });

  it('Owner GET /settings returns 200 payload', async () => {
    settingsService.getManifest.mockResolvedValue({
      writableSections: ['company'],
      sections: { company: { companyName: 'Yelo Laundry' } },
    });

    const response = await controller.getSettings();

    expect(response.success).toBe(true);
    expect(response.data.sections.company).toEqual({
      companyName: 'Yelo Laundry',
    });
  });

  it('Owner PATCH /settings/:section returns success payload', async () => {
    settingsService.updateSection.mockResolvedValue({
      section: 'company',
      data: { companyName: 'Updated' },
    });

    const response = await controller.updateSection(
      { section: 'company' },
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
    expect(response.success).toBe(true);
    expect(response.data.data).toEqual({ companyName: 'Updated' });
  });

  it('Manager GET /settings/:section delegates to service', async () => {
    settingsService.getSection.mockResolvedValue({ companyName: 'Yelo' });

    const response = await controller.getSection({ section: 'company' });

    expect(response.success).toBe(true);
    expect(response.data).toEqual({ companyName: 'Yelo' });
  });
});
