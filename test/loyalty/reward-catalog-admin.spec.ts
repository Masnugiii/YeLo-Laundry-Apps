import { BadRequestException } from '@nestjs/common';
import { RewardCatalogType } from '@prisma/client';
import { RewardCatalogAdminService } from '../../src/loyalty/reward-catalog-admin.service';

describe('RewardCatalogAdminService', () => {
  const prisma = {
    rewardCatalogItem: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };
  const auditService = { logChange: jest.fn() };

  let service: RewardCatalogAdminService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new RewardCatalogAdminService(
      prisma as never,
      auditService as never,
    );
  });

  it('rejects negative cost points on create', async () => {
    prisma.rewardCatalogItem.findFirst.mockResolvedValue(null);

    await expect(
      service.create(
        {
          code: 'TEST',
          name: 'Test',
          type: RewardCatalogType.PHYSICAL_GOODS,
          costPoints: -1,
        },
        'emp-1',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects CKS without free KG', async () => {
    prisma.rewardCatalogItem.findFirst.mockResolvedValue(null);

    await expect(
      service.create(
        {
          code: 'CKS_TEST',
          name: 'CKS Test',
          type: RewardCatalogType.LAUNDRY_KG,
          costPoints: 5,
          serviceDurationDays: 3,
        },
        'emp-1',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('updates cost points for existing catalog item', async () => {
    const existing = {
      id: 'cat-1',
      code: 'CKS_5KG',
      name: 'CKS 5 KG',
      description: null,
      type: RewardCatalogType.LAUNDRY_KG,
      costPoints: 5,
      isActive: true,
      kg: 5,
      serviceType: 'CKS',
      serviceDurationDays: 3,
      stock: null,
      metadata: {},
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    prisma.rewardCatalogItem.findFirst
      .mockResolvedValueOnce(existing)
      .mockResolvedValueOnce(null);
    prisma.rewardCatalogItem.update.mockResolvedValue({
      ...existing,
      costPoints: 6,
    });

    const result = await service.update(
      'cat-1',
      { costPoints: 6 },
      'emp-1',
    );

    expect(result.costPoints).toBe(6);
    expect(auditService.logChange).toHaveBeenCalled();
  });
});
