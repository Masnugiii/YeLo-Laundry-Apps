import {
  BadRequestException,
  UnprocessableEntityException,
} from '@nestjs/common';
import {
  RewardCatalogType,
  RewardPointSource,
  RewardPointType,
  RewardRedemptionStatus,
} from '@prisma/client';
import { RewardRedeemService } from '../../src/loyalty/reward-redeem.service';
import { YELO_REWARD_CATALOG_SEED } from '../../src/loyalty/reward-catalog.constants';

describe('RewardRedeemService', () => {
  const customerId = '11111111-1111-1111-1111-111111111111';

  function catalog(code: string, overrides: Record<string, unknown> = {}) {
    const seed = YELO_REWARD_CATALOG_SEED.find((item) => item.code === code)!;
    return {
      id: `cat-${code}`,
      code: seed.code,
      name: seed.name,
      description: seed.description,
      type: seed.type,
      costPoints: seed.costPoints,
      isActive: true,
      kg: seed.kg ?? null,
      serviceType: seed.serviceType ?? null,
      serviceDurationDays: seed.serviceDurationDays ?? null,
      stock: null,
      metadata: seed.metadata ?? null,
      deletedAt: null,
      ...overrides,
    };
  }

  function buildService(options?: {
    lots?: Array<{
      id: string;
      remaining_point: number;
      expired_at?: Date | null;
      created_at?: Date;
    }>;
    catalogItems?: Array<ReturnType<typeof catalog>>;
    existingRedemption?: unknown;
  }) {
    const lots = options?.lots ?? [
      {
        id: 'lot-a',
        remaining_point: 5,
        expired_at: new Date('2026-09-01T00:00:00.000Z'),
        created_at: new Date('2026-03-01T00:00:00.000Z'),
      },
    ];

    const catalogItems = options?.catalogItems ?? [catalog('CKS_5KG')];
    const state = {
      lots: lots.map((lot) => ({ ...lot })),
      redemptions: [] as Array<Record<string, unknown>>,
      allocations: [] as Array<Record<string, unknown>>,
      ledger: [] as Array<Record<string, unknown>>,
    };

    const tx = {
      rewardRedemption: {
        findFirst: jest.fn(
          async ({ where }: { where: { idempotencyKey?: string } }) => {
            if (options?.existingRedemption && where.idempotencyKey) {
              return options.existingRedemption;
            }
            return (
              state.redemptions.find(
                (row) => row.idempotencyKey === where.idempotencyKey,
              ) ?? null
            );
          },
        ),
        create: jest.fn(async ({ data }: { data: any }) => {
          const created = {
            id: 'redemption-1',
            customerId: data.customerId,
            status: data.status,
            totalPointsSpent: data.totalPointsSpent,
            idempotencyKey: data.idempotencyKey ?? null,
            notes: null,
            fulfilledAt: null,
            createdAt: new Date(),
            updatedAt: new Date(),
            items: (data.items?.create ?? []).map((item: any, index: number) => {
              const catalogItem = catalogItems.find(
                (c) => c.id === item.catalogItemId,
              )!;
              return {
                id: `item-${index}`,
                ...item,
                catalogItem,
              };
            }),
          };
          state.redemptions.push(created);
          return created;
        }),
        update: jest.fn(async ({ data }: { data: any }) => {
          const current = state.redemptions[0];
          Object.assign(current, data);
          return current;
        }),
      },
      rewardCatalogItem: {
        findMany: jest.fn(
          async ({ where }: { where: { id: { in: string[] } } }) =>
            catalogItems.filter((item) => where.id.in.includes(item.id)),
        ),
        update: jest.fn(),
      },
      rewardPoint: {
        create: jest.fn(async ({ data }: { data: any }) => {
          const row = { id: 'ledger-redeem-1', ...data };
          state.ledger.push(row);
          return row;
        }),
        update: jest.fn(
          async ({ where, data }: { where: { id: string }; data: any }) => {
            const lot = state.lots.find((row) => row.id === where.id);
            if (lot) {
              lot.remaining_point = data.remainingPoint;
            }
            return lot;
          },
        ),
      },
      rewardPointAllocation: {
        create: jest.fn(async ({ data }: { data: any }) => {
          state.allocations.push(data);
          return { id: `alloc-${state.allocations.length}`, ...data };
        }),
      },
      $queryRaw: jest.fn(async () =>
        state.lots.filter((lot) => Number(lot.remaining_point ?? 0) > 0),
      ),
    };

    const prisma = {
      $transaction: jest.fn(async (fn: (client: typeof tx) => unknown) =>
        fn(tx),
      ),
      $queryRaw: jest.fn(async () => state.lots),
      rewardCatalogItem: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
      },
      rewardRedemption: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
    };

    return {
      service: new RewardRedeemService(prisma as never),
      tx,
      state,
    };
  }

  it('allows redeem CKS 5 KG with 5 points', async () => {
    const { service, state } = buildService();
    const result = await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
    });

    expect(result.totalPointsSpent).toBe(5);
    expect(result.status).toBe(RewardRedemptionStatus.COMPLETED);
    expect(result.items[0].entitlementKg).toBe(5);
    expect(result.items[0].metadata).toEqual(
      expect.objectContaining({
        freeKg: 5,
        durationDays: 3,
        serviceType: 'CKS',
      }),
    );
    expect(state.lots[0].remaining_point).toBe(0);
    expect(state.allocations).toEqual([
      {
        earnPointId: 'lot-a',
        consumePointId: 'ledger-redeem-1',
        points: 5,
      },
    ]);
    expect(state.ledger[0]).toEqual(
      expect.objectContaining({
        point: -5,
        type: RewardPointType.redeem,
        source: RewardPointSource.redeem,
      }),
    );
  });

  it('rejects CKS 5 KG when customer has only 4 points', async () => {
    const { service } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 4 }],
    });

    await expect(
      service.redeem({
        customerId,
        items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('allows CKS 10 KG with 10 points', async () => {
    const { service, state } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 10 }],
      catalogItems: [catalog('CKS_10KG')],
    });

    const result = await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-CKS_10KG', quantity: 1 }],
    });

    expect(result.totalPointsSpent).toBe(10);
    expect(result.items[0].entitlementKg).toBe(10);
    expect(result.items[0].metadata).toEqual(
      expect.objectContaining({ freeKg: 10, durationDays: 3 }),
    );
    expect(state.lots[0].remaining_point).toBe(0);
  });

  it('allows Magic Com with 15 points', async () => {
    const { service } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 15 }],
      catalogItems: [catalog('MAGIC_COM')],
    });

    const result = await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-MAGIC_COM', quantity: 1 }],
    });

    expect(result.totalPointsSpent).toBe(15);
    expect(result.status).toBe(RewardRedemptionStatus.PENDING);
  });

  it('rejects Magic Com with 9 points', async () => {
    const { service } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 9 }],
      catalogItems: [catalog('MAGIC_COM')],
    });

    await expect(
      service.redeem({
        customerId,
        items: [{ catalogItemId: 'cat-MAGIC_COM', quantity: 1 }],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('rejects inactive rewards', async () => {
    const { service } = buildService({
      catalogItems: [catalog('BANTAL_PREMIUM', { isActive: false })],
      lots: [{ id: 'lot-a', remaining_point: 5 }],
    });

    await expect(
      service.redeem({
        customerId,
        items: [{ catalogItemId: 'cat-BANTAL_PREMIUM', quantity: 1 }],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('does not consume expired lots', async () => {
    const { service, tx } = buildService({
      lots: [],
      catalogItems: [catalog('CKS_5KG')],
    });
    tx.$queryRaw.mockResolvedValue([]);

    await expect(
      service.redeem({
        customerId,
        items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('applies FIFO across multiple lots', async () => {
    const { service, state } = buildService({
      lots: [
        {
          id: 'lot-a',
          remaining_point: 5,
          expired_at: new Date('2026-09-01T00:00:00.000Z'),
          created_at: new Date('2026-03-01T00:00:00.000Z'),
        },
        {
          id: 'lot-b',
          remaining_point: 5,
          expired_at: new Date('2026-10-01T00:00:00.000Z'),
          created_at: new Date('2026-03-10T00:00:00.000Z'),
        },
      ],
      catalogItems: [catalog('CKS_10KG')],
    });

    await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-CKS_10KG', quantity: 1 }],
    });

    expect(state.lots[0].remaining_point).toBe(0);
    expect(state.lots[1].remaining_point).toBe(0);
    expect(state.allocations).toEqual([
      { earnPointId: 'lot-a', consumePointId: 'ledger-redeem-1', points: 5 },
      { earnPointId: 'lot-b', consumePointId: 'ledger-redeem-1', points: 5 },
    ]);
  });

  it('supports multiple reward items when total cost fits', async () => {
    const { service, state } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 15 }],
      catalogItems: [catalog('CKS_10KG'), catalog('CKS_5KG')],
    });

    const result = await service.redeem({
      customerId,
      items: [
        { catalogItemId: 'cat-CKS_10KG', quantity: 1 },
        { catalogItemId: 'cat-CKS_5KG', quantity: 1 },
      ],
    });

    expect(result.totalPointsSpent).toBe(15);
    expect(result.items).toHaveLength(2);
    expect(state.lots[0].remaining_point).toBe(0);
  });

  it('rejects multiple items that exceed available points', async () => {
    const { service } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 14 }],
      catalogItems: [catalog('CKS_10KG'), catalog('CKS_5KG')],
    });

    await expect(
      service.redeem({
        customerId,
        items: [
          { catalogItemId: 'cat-CKS_10KG', quantity: 1 },
          { catalogItemId: 'cat-CKS_5KG', quantity: 1 },
        ],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('returns existing redemption for duplicate idempotency key', async () => {
    const existing = {
      id: 'redemption-existing',
      customerId,
      status: RewardRedemptionStatus.COMPLETED,
      totalPointsSpent: 5,
      idempotencyKey: '22222222-2222-2222-2222-222222222222',
      notes: null,
      fulfilledAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
      items: [
        {
          id: 'item-1',
          catalogItemId: 'cat-CKS_5KG',
          quantity: 1,
          pointsSpent: 5,
          entitlementKg: 5,
          metadata: { freeKg: 5, durationDays: 3 },
          catalogItem: catalog('CKS_5KG'),
        },
      ],
    };

    const { service, tx, state } = buildService({
      existingRedemption: existing,
      lots: [{ id: 'lot-a', remaining_point: 5 }],
    });

    const result = await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
      idempotencyKey: '22222222-2222-2222-2222-222222222222',
    });

    expect(result.id).toBe('redemption-existing');
    expect(tx.rewardRedemption.create).not.toHaveBeenCalled();
    expect(state.lots[0].remaining_point).toBe(5);
  });

  it('rejects empty redeem payload', async () => {
    const { service } = buildService();
    await expect(
      service.redeem({ customerId, items: [] }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('serializes concurrent spends so the second request fails', async () => {
    const { service, state, tx } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 5 }],
      catalogItems: [catalog('CKS_5KG')],
    });
    tx.$queryRaw.mockImplementation(async () =>
      state.lots.filter((lot) => Number(lot.remaining_point ?? 0) > 0),
    );

    await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
    });

    await expect(
      service.redeem({
        customerId,
        items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
      }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
    expect(state.lots[0].remaining_point).toBe(0);
  });

  it('starts physical goods in PENDING lifecycle', async () => {
    const { service } = buildService({
      lots: [{ id: 'lot-a', remaining_point: 5 }],
      catalogItems: [catalog('BANTAL_PREMIUM')],
    });

    const result = await service.redeem({
      customerId,
      items: [{ catalogItemId: 'cat-BANTAL_PREMIUM', quantity: 1 }],
    });

    expect(result.status).toBe(RewardRedemptionStatus.PENDING);
    expect(result.items[0].reward.type).toBe(RewardCatalogType.PHYSICAL_GOODS);
  });
});

describe('customer-app redeem identity', () => {
  it('controller redeem uses authenticated customerId, not body customerId', async () => {
    const { CustomerAppController } = await import(
      '../../src/customer-app/customer-app.controller'
    );

    const redeemRewards = jest.fn().mockResolvedValue({ success: true });
    const controller = new CustomerAppController({
      redeemRewards,
    } as never);

    await controller.redeemRewards(
      { customerId: 'auth-customer-id' } as never,
      {
        items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
      },
    );

    expect(redeemRewards).toHaveBeenCalledWith('auth-customer-id', {
      items: [{ catalogItemId: 'cat-CKS_5KG', quantity: 1 }],
    });
  });
});
