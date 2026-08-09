import { BadRequestException, ConflictException } from '@nestjs/common';
import { CatalogService } from '../../src/master-data/catalog.service';

describe('CatalogService', () => {
  const auditService = {
    logChange: jest.fn(),
  };

  let prisma: {
    service: {
      findMany: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    servicePrice: {
      findMany: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      updateMany: jest.Mock;
      count: jest.Mock;
    };
    $transaction: jest.Mock;
  };

  prisma = {
    service: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    servicePrice: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      count: jest.fn(),
    },
    $transaction: jest.fn(async (callback: (client: typeof prisma) => unknown) =>
      callback(prisma),
    ),
  };

  let service: CatalogService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new CatalogService(prisma as never, auditService as never);
  });

  it('lists services', async () => {
    prisma.service.findMany.mockResolvedValue([{ id: 'svc-1' }]);
    const result = await service.listServices();
    expect(result).toHaveLength(1);
  });

  it('creates service and writes audit log', async () => {
    prisma.service.findFirst.mockResolvedValue(null);
    prisma.service.create.mockResolvedValue({ id: 'svc-1', serviceCode: 'CKS' });

    const result = await service.createService(
      {
        categoryId: 'cat-1',
        serviceCode: 'CKS',
        serviceName: 'Cuci Kering Setrika',
        unitType: 'kg',
      },
      'owner-id',
    );

    expect(result.id).toBe('svc-1');
    expect(auditService.logChange).toHaveBeenCalled();
  });

  it('rejects duplicate service code', async () => {
    prisma.service.findFirst.mockResolvedValue({ id: 'existing' });

    await expect(
      service.createService(
        {
          categoryId: 'cat-1',
          serviceCode: 'CKS',
          serviceName: 'Duplicate',
          unitType: 'kg',
        },
        'owner-id',
      ),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('enforces single active price per service', async () => {
    prisma.service.findFirst.mockResolvedValue({ id: 'svc-1' });
    prisma.servicePrice.updateMany.mockResolvedValue({ count: 1 });
    prisma.servicePrice.create.mockResolvedValue({
      id: 'price-1',
      serviceId: 'svc-1',
      isActive: true,
    });

    await service.createPrice(
      { serviceId: 'svc-1', price: 7000, isActive: true },
      'owner-id',
    );

    expect(prisma.servicePrice.updateMany).toHaveBeenCalled();
  });

  it('rejects activating a second active price', async () => {
    prisma.servicePrice.findFirst.mockResolvedValue({
      id: 'price-1',
      serviceId: 'svc-1',
      isActive: false,
    });
    prisma.servicePrice.updateMany.mockResolvedValue({ count: 0 });
    prisma.servicePrice.count.mockResolvedValue(1);

    await expect(
      service.updatePrice('price-1', { isActive: true }, 'owner-id'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
