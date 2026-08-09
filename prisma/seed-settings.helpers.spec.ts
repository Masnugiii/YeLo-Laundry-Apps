import {
  buildDefaultAttendanceTimes,
  seedDefaultAttendanceSetting,
  seedDefaultServicePrices,
} from './seed-settings.helpers';

describe('seed-settings.helpers', () => {
  it('seeds default ServicePrice rows for active services', async () => {
    const createdPrices: Array<{ serviceId: string; price: number }> = [];

    const tx = {
      service: {
        findFirst: jest.fn(async ({ where }: { where: { serviceCode: string } }) => {
          if (where.serviceCode === 'CKS') {
            return { id: 'service-cks' };
          }
          return null;
        }),
      },
      servicePrice: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn(async ({ data }: { data: { serviceId: string; price: number } }) => {
          createdPrices.push(data);
        }),
      },
    };

    const created = await seedDefaultServicePrices(tx as never, ['CKS', 'MISSING']);

    expect(created).toBe(1);
    expect(tx.service.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          serviceCode: 'CKS',
          isActive: true,
          deletedAt: null,
        }),
      }),
    );
    expect(createdPrices[0]).toEqual(
      expect.objectContaining({
        serviceId: 'service-cks',
        price: 7000,
        isActive: true,
      }),
    );
  });

  it('skips inactive services and duplicate active prices', async () => {
    const create = jest.fn();

    const tx = {
      service: {
        findFirst: jest.fn(async ({ where }: { where: { serviceCode: string } }) => {
          if (where.serviceCode === 'CKS') {
            return { id: 'service-cks' };
          }
          return null;
        }),
      },
      servicePrice: {
        findFirst: jest.fn(async ({ where }: { where: { serviceId: string } }) => {
          if (where.serviceId === 'service-cks') {
            return { id: 'existing-price' };
          }
          return null;
        }),
        create,
      },
    };

    const created = await seedDefaultServicePrices(tx as never, ['CKS', 'INACTIVE']);

    expect(created).toBe(0);
    expect(create).not.toHaveBeenCalled();
  });

  it('is idempotent when seed runs twice', async () => {
    let activePriceExists = false;
    const create = jest.fn(async () => {
      activePriceExists = true;
    });

    const tx = {
      service: {
        findFirst: jest.fn(async () => ({ id: 'service-cks' })),
      },
      servicePrice: {
        findFirst: jest.fn(async () => (activePriceExists ? { id: 'price-1' } : null)),
        create,
      },
    };

    const firstRun = await seedDefaultServicePrices(tx as never, ['CKS']);
    const secondRun = await seedDefaultServicePrices(tx as never, ['CKS']);

    expect(firstRun).toBe(1);
    expect(secondRun).toBe(0);
    expect(create).toHaveBeenCalledTimes(1);
  });

  it('seeds default AttendanceSetting when none exists', async () => {
    const tx = {
      attendanceSetting: {
        findFirst: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue({ id: 'att-1' }),
      },
    };

    const result = await seedDefaultAttendanceSetting(tx as never);

    expect(result).toBe('created');
    expect(tx.attendanceSetting.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        lateToleranceMinutes: 15,
        overtimeEnabled: false,
        isActive: true,
        workStartTime: buildDefaultAttendanceTimes().workStartTime,
        workEndTime: buildDefaultAttendanceTimes().workEndTime,
      }),
    });
  });

  it('skips AttendanceSetting seed when active record exists', async () => {
    const tx = {
      attendanceSetting: {
        findFirst: jest.fn().mockResolvedValue({ id: 'existing' }),
        create: jest.fn(),
      },
    };

    const result = await seedDefaultAttendanceSetting(tx as never);

    expect(result).toBe('existing');
    expect(tx.attendanceSetting.create).not.toHaveBeenCalled();
  });

  it('is idempotent for AttendanceSetting when seed runs twice', async () => {
    let activeSettingExists = false;
    const create = jest.fn(async () => {
      activeSettingExists = true;
    });

    const tx = {
      attendanceSetting: {
        findFirst: jest.fn(async () =>
          activeSettingExists ? { id: 'att-1' } : null,
        ),
        create,
      },
    };

    const firstRun = await seedDefaultAttendanceSetting(tx as never);
    const secondRun = await seedDefaultAttendanceSetting(tx as never);

    expect(firstRun).toBe('created');
    expect(secondRun).toBe('existing');
    expect(create).toHaveBeenCalledTimes(1);
  });
});
