import { RewardPointSource, RewardPointType } from '@prisma/client';
import { LoyaltyProcessorService } from '../../src/loyalty/loyalty-processor.service';
import { RewardService } from '../../src/loyalty/reward.service';

describe('LoyaltyProcessorService earning', () => {
  const prisma = {
    order: { findFirst: jest.fn() },
    payment: { findMany: jest.fn() },
    walletTransaction: { findFirst: jest.fn() },
  };
  const settingsService = {
    getSettings: jest.fn().mockResolvedValue({
      cashback: { enabled: false },
    }),
  };
  const rewardService = {
    earnFromPayment: jest.fn(),
  };
  const walletRepository = {
    generateNextReferenceNumber: jest.fn(),
    applyMutation: jest.fn(),
  };

  let service: LoyaltyProcessorService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new LoyaltyProcessorService(
      prisma as never,
      settingsService as never,
      rewardService as never,
      walletRepository as never,
    );
  });

  it('does not earn on unpaid / partial payment status (no installment)', async () => {
    prisma.order.findFirst.mockResolvedValue({
      id: 'order-1',
      customerId: 'cust-1',
      orderStatus: 'COMPLETED',
      paymentStatus: 'UNPAID',
      items: [{ subtotal: 100000 }],
    });

    await expect(service.processOrderCompleted('order-1')).resolves.toBeNull();
    expect(rewardService.earnFromPayment).not.toHaveBeenCalled();
  });

  it('excludes YELO_WALLET payments from laundry earning amount', async () => {
    prisma.order.findFirst.mockResolvedValue({
      id: 'order-1',
      customerId: 'cust-1',
      orderStatus: 'COMPLETED',
      paymentStatus: 'PAID',
      items: [{ subtotal: 250000 }],
    });
    prisma.payment.findMany.mockResolvedValue([
      {
        amount: 250000,
        paymentMethod: { code: 'YELO_WALLET' },
      },
    ]);

    await service.processOrderCompleted('order-1', 'emp-1');

    expect(rewardService.earnFromPayment).toHaveBeenCalledWith(
      'cust-1',
      'order-1',
      0,
      'emp-1',
    );
  });

  it('earns only on non-wallet portion for mixed payments', async () => {
    prisma.order.findFirst.mockResolvedValue({
      id: 'order-2',
      customerId: 'cust-1',
      orderStatus: 'COMPLETED',
      paymentStatus: 'PAID',
      items: [{ subtotal: 300000 }],
    });
    prisma.payment.findMany.mockResolvedValue([
      { amount: 250000, paymentMethod: { code: 'YELO_WALLET' } },
      { amount: 50000, paymentMethod: { code: 'CASH' } },
    ]);

    await service.processOrderCompleted('order-2', 'emp-1');

    expect(rewardService.earnFromPayment).toHaveBeenCalledWith(
      'cust-1',
      'order-2',
      50000,
      'emp-1',
    );
  });
});

describe('RewardService earning + clawback', () => {
  const settingsService = {
    getSettings: jest.fn().mockResolvedValue({ pointExpirationDays: 180 }),
  };
  const membershipService = {
    getRewardSummary: jest.fn().mockResolvedValue({ currentPoint: 0 }),
  };

  function buildPrismaMock(overrides: Record<string, unknown> = {}) {
    const rewardPoint = {
      findFirst: jest.fn().mockResolvedValue(null),
      create: jest.fn(),
      update: jest.fn(),
      findMany: jest.fn().mockResolvedValue([]),
      ...(overrides.rewardPoint as object),
    };
    const rewardPointAllocation = {
      create: jest.fn(),
      ...(overrides.rewardPointAllocation as object),
    };
    const prisma = {
      rewardPoint,
      rewardPointAllocation,
      $transaction: jest.fn(async (fn: (tx: unknown) => unknown) =>
        fn({ rewardPoint, rewardPointAllocation }),
      ),
    };
    return prisma;
  }

  it('creates laundry earn with formula, expiration, and remainingPoint', async () => {
    const prisma = buildPrismaMock();
    prisma.rewardPoint.create.mockResolvedValue({
      id: 'rp-1',
      point: 5,
      remainingPoint: 5,
      type: RewardPointType.earn,
      source: RewardPointSource.laundry_payment,
    });

    const service = new RewardService(
      prisma as never,
      settingsService as never,
      membershipService as never,
    );

    const result = await service.earnFromPayment(
      'cust-1',
      'order-1',
      250_000,
      'emp-1',
    );

    expect(result?.point).toBe(5);
    expect(prisma.rewardPoint.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          point: 5,
          remainingPoint: 5,
          type: RewardPointType.earn,
          source: RewardPointSource.laundry_payment,
          referenceType: 'ORDER',
          referenceId: 'order-1',
          expiredAt: expect.any(Date),
        }),
      }),
    );
  });

  it('rejects duplicate order earning', async () => {
    const existing = {
      id: 'rp-existing',
      point: 2,
      referenceId: 'order-1',
      type: RewardPointType.earn,
      source: RewardPointSource.laundry_payment,
    };
    const prisma = buildPrismaMock({
      rewardPoint: {
        findFirst: jest.fn().mockResolvedValue(existing),
        create: jest.fn(),
      },
    });

    const service = new RewardService(
      prisma as never,
      settingsService as never,
      membershipService as never,
    );

    const result = await service.earnFromPayment('cust-1', 'order-1', 100_000);
    expect(result).toEqual(existing);
    expect(prisma.rewardPoint.create).not.toHaveBeenCalled();
  });

  it('creates deposit earn and rejects duplicate deposit reference', async () => {
    const prisma = buildPrismaMock();
    prisma.rewardPoint.create.mockResolvedValue({
      id: 'rp-dep',
      point: 6,
      source: RewardPointSource.deposit,
    });

    const service = new RewardService(
      prisma as never,
      settingsService as never,
      membershipService as never,
    );

    await service.earnFromDeposit(
      'cust-1',
      250_000,
      'WALLET_TOP_UP',
      'topup-1',
    );
    expect(prisma.rewardPoint.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          point: 6,
          source: RewardPointSource.deposit,
          referenceType: 'WALLET_TOP_UP',
          referenceId: 'topup-1',
        }),
      }),
    );

    prisma.rewardPoint.findFirst.mockResolvedValue({
      id: 'rp-dep',
      point: 6,
    });
    prisma.rewardPoint.create.mockClear();

    const dup = await service.earnFromDeposit(
      'cust-1',
      250_000,
      'WALLET_TOP_UP',
      'topup-1',
    );
    expect(dup?.id).toBe('rp-dep');
    expect(prisma.rewardPoint.create).not.toHaveBeenCalled();
  });

  it('returns null for below-minimum deposit', async () => {
    const prisma = buildPrismaMock();
    const service = new RewardService(
      prisma as never,
      settingsService as never,
      membershipService as never,
    );

    await expect(
      service.earnFromDeposit('cust-1', 249_999, 'WALLET_TOP_UP', 'topup-2'),
    ).resolves.toBeNull();
    expect(prisma.rewardPoint.create).not.toHaveBeenCalled();
  });

  it('claws back exact earn points and is idempotent on second refund', async () => {
    const earn = {
      id: 'earn-1',
      point: 5,
      remainingPoint: 5,
      type: RewardPointType.earn,
      source: RewardPointSource.laundry_payment,
    };
    const clawback = {
      id: 'claw-1',
      point: -5,
      type: RewardPointType.clawback,
      referenceId: 'order-1',
    };

    const findFirst = jest
      .fn()
      .mockResolvedValueOnce(earn) // find earn
      .mockResolvedValueOnce(null) // no existing clawback
      .mockResolvedValueOnce(earn) // second call earn
      .mockResolvedValueOnce(clawback); // existing clawback

    const prisma = buildPrismaMock({
      rewardPoint: {
        findFirst,
        create: jest.fn().mockResolvedValue(clawback),
        update: jest.fn(),
        findMany: jest.fn().mockResolvedValue([{ point: 5, type: 'earn' }]),
      },
    });

    const service = new RewardService(
      prisma as never,
      settingsService as never,
      membershipService as never,
    );

    const first = await service.clawbackFromOrder('cust-1', 'order-1', 'emp-1');
    expect(first?.point).toBe(-5);
    expect(prisma.rewardPoint.create).toHaveBeenCalledTimes(1);
    expect(prisma.rewardPoint.update).toHaveBeenCalledWith({
      where: { id: 'earn-1' },
      data: { remainingPoint: 0 },
    });

    const second = await service.clawbackFromOrder('cust-1', 'order-1', 'emp-1');
    expect(second?.id).toBe('claw-1');
    expect(prisma.rewardPoint.create).toHaveBeenCalledTimes(1);
  });
});
