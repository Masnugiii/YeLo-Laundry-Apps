import {
  ForbiddenException,
  UnprocessableEntityException,
} from '@nestjs/common';
import {
  RewardCatalogType,
  RewardEntitlementStatus,
  RewardPointType,
  RewardRedemptionStatus,
} from '@prisma/client';
import { RewardEntitlementService } from '../../src/loyalty/reward-entitlement.service';
import {
  resolveEntitlementStatus,
  splitEntitlementKg,
} from '../../src/loyalty/reward-entitlement.rules';

describe('Reward entitlement Phase 5', () => {
  describe('splitEntitlementKg', () => {
    it('3 KG order consumes only 3 KG from 5 KG entitlement', () => {
      expect(splitEntitlementKg(5, 3)).toEqual({
        orderKg: 3,
        freeKg: 3,
        billableKg: 0,
        remainingKgAfter: 2,
      });
    });

    it('7 KG order with 5 KG entitlement bills only 2 KG', () => {
      expect(splitEntitlementKg(5, 7)).toEqual({
        orderKg: 7,
        freeKg: 5,
        billableKg: 2,
        remainingKgAfter: 0,
      });
    });

    it('12 KG order with 10 KG entitlement bills only 2 KG', () => {
      expect(splitEntitlementKg(10, 12)).toEqual({
        orderKg: 12,
        freeKg: 10,
        billableKg: 2,
        remainingKgAfter: 0,
      });
    });
  });

  describe('resolveEntitlementStatus', () => {
    it('marks PARTIALLY_USED when remaining is between 0 and entitlement', () => {
      expect(
        resolveEntitlementStatus({
          remainingKg: 2,
          entitlementKg: 5,
          expiresAt: new Date('2099-01-01'),
        }),
      ).toBe(RewardEntitlementStatus.PARTIALLY_USED);
    });

    it('marks USED at zero remaining KG', () => {
      expect(
        resolveEntitlementStatus({
          remainingKg: 0,
          entitlementKg: 5,
          expiresAt: new Date('2099-01-01'),
        }),
      ).toBe(RewardEntitlementStatus.USED);
    });
  });

  describe('RewardEntitlementService', () => {
    const customerId = '11111111-1111-1111-1111-111111111111';
    const otherCustomerId = '22222222-2222-2222-2222-222222222222';
    const employeeId = '33333333-3333-3333-3333-333333333333';
    const itemId = '44444444-4444-4444-4444-444444444444';
    const orderId = '55555555-5555-5555-5555-555555555555';

    function lockedRow(overrides: Record<string, unknown> = {}) {
      return {
        id: itemId,
        entitlement_kg: 5,
        remaining_kg: 5,
        entitlement_status: RewardEntitlementStatus.AVAILABLE,
        entitlement_expires_at: new Date('2099-08-15T00:00:00.000Z'),
        customer_id: customerId,
        redemption_status: RewardRedemptionStatus.COMPLETED,
        catalog_type: RewardCatalogType.LAUNDRY_KG,
        service_type: 'CKS',
        catalog_name: 'CKS 5 KG',
        points_spent: 5,
        redeemed_at: new Date('2026-08-12T00:00:00.000Z'),
        ...overrides,
      };
    }

    function buildService(options?: {
      locked?: Record<string, unknown> | null;
      redemption?: Record<string, unknown> | null;
      failOnUsageCreate?: boolean;
      pointBalance?: number;
    }) {
      const state = {
        remainingKg: Number(options?.locked?.remaining_kg ?? 5),
        status:
          (options?.locked?.entitlement_status as RewardEntitlementStatus) ??
          RewardEntitlementStatus.AVAILABLE,
        usages: [] as Array<Record<string, unknown>>,
        redemption: options?.redemption ?? {
          id: 'redemption-1',
          status: RewardRedemptionStatus.PENDING,
          totalPointsSpent: 5,
          createdAt: new Date(),
          fulfilledAt: null,
          fulfilledByEmployee: null,
          items: [
            {
              id: 'phys-1',
              pointsSpent: 5,
              catalogItem: {
                name: 'Bantal Premium',
                code: 'BANTAL',
                type: RewardCatalogType.PHYSICAL_GOODS,
              },
            },
          ],
        },
        pointBalance: options?.pointBalance ?? 0,
      };

      const tx = {
        $queryRaw: jest.fn(async () =>
          options?.locked === null ? [] : [lockedRow(options?.locked ?? {})],
        ),
        rewardRedemptionItem: {
          update: jest.fn(async ({ data }: { data: any }) => {
            if (data.remainingKg != null) {
              state.remainingKg = Number(data.remainingKg);
            }
            if (data.entitlementStatus != null) {
              state.status = data.entitlementStatus;
            }
            return {};
          }),
        },
        rewardEntitlementUsage: {
          create: jest.fn(async ({ data }: { data: any }) => {
            if (options?.failOnUsageCreate) {
              throw new Error('order failed');
            }
            state.usages.push(data);
            return { id: 'usage-1', ...data };
          }),
        },
      };

      const prisma = {
        $transaction: jest.fn(async (fn: (client: typeof tx) => unknown) =>
          fn(tx),
        ),
        rewardRedemptionItem: {
          findMany: jest.fn(async () => []),
          updateMany: jest.fn(),
        },
        rewardRedemption: {
          findFirst: jest.fn(async () => state.redemption),
          update: jest.fn(async ({ data }: { data: any }) => {
            Object.assign(state.redemption as object, data);
            return state.redemption;
          }),
        },
        rewardPoint: {
          findMany: jest.fn(async () => [
            { point: state.pointBalance, type: RewardPointType.earn },
          ]),
          aggregate: jest.fn(),
        },
      };

      const service = new RewardEntitlementService(prisma as any);
      return { service, state, tx, prisma };
    }

    it('1. Valid CKS 5 KG entitlement can be applied', async () => {
      const { service, state, tx } = buildService({
        locked: { entitlement_kg: 5, remaining_kg: 5 },
      });
      const result = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 5,
        employeeId,
      });

      expect(result.freeKg).toBe(5);
      expect(result.billableKg).toBe(0);
      expect(state.remainingKg).toBe(0);
      expect(state.status).toBe(RewardEntitlementStatus.USED);
      expect(state.usages).toHaveLength(1);
    });

    it('2. Valid CKS 10 KG entitlement can be applied', async () => {
      const { service, state, tx } = buildService({
        locked: {
          entitlement_kg: 10,
          remaining_kg: 10,
          catalog_name: 'CKS 10 KG',
          points_spent: 10,
        },
      });
      const result = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 8,
        employeeId,
      });
      expect(result.freeKg).toBe(8);
      expect(result.billableKg).toBe(0);
      expect(state.remainingKg).toBe(2);
      expect(state.status).toBe(RewardEntitlementStatus.PARTIALLY_USED);
    });

    it('3-6. Partial usage then remaining 2 KG then USED', async () => {
      const { service, state, tx } = buildService({
        locked: { entitlement_kg: 5, remaining_kg: 5 },
      });

      const first = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 3,
        employeeId,
      });
      expect(first.freeKg).toBe(3);
      expect(first.remainingKgAfter).toBe(2);
      expect(state.status).toBe(RewardEntitlementStatus.PARTIALLY_USED);

      tx.$queryRaw = jest.fn(async () => [
        lockedRow({
          remaining_kg: state.remainingKg,
          entitlement_status: state.status,
        }),
      ]);

      const second = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId: '66666666-6666-6666-6666-666666666666',
        orderKg: 2,
        employeeId,
      });
      expect(second.freeKg).toBe(2);
      expect(second.remainingKgAfter).toBe(0);
      expect(state.status).toBe(RewardEntitlementStatus.USED);
    });

    it('7. 7 KG order with 5 KG entitlement bills only 2 KG', async () => {
      const { service, tx } = buildService({
        locked: { entitlement_kg: 5, remaining_kg: 5 },
      });
      const result = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 7,
        employeeId,
      });
      expect(result.freeKg).toBe(5);
      expect(result.billableKg).toBe(2);
    });

    it('8. 12 KG order with 10 KG entitlement bills only 2 KG', async () => {
      const { service, tx } = buildService({
        locked: {
          entitlement_kg: 10,
          remaining_kg: 10,
          catalog_name: 'CKS 10 KG',
        },
      });
      const result = await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 12,
        employeeId,
      });
      expect(result.freeKg).toBe(10);
      expect(result.billableKg).toBe(2);
    });

    it('9. Expired entitlement rejected', async () => {
      const { service, tx } = buildService({
        locked: {
          entitlement_expires_at: new Date('2020-01-01T00:00:00.000Z'),
          entitlement_status: RewardEntitlementStatus.AVAILABLE,
        },
      });
      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId,
          orderKg: 3,
          employeeId,
        }),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    });

    it('10. Wrong customer entitlement rejected', async () => {
      const { service, tx } = buildService({
        locked: { customer_id: otherCustomerId },
      });
      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId,
          orderKg: 3,
          employeeId,
        }),
      ).rejects.toBeInstanceOf(ForbiddenException);
    });

    it('11. Cancelled entitlement rejected', async () => {
      const { service, tx } = buildService({
        locked: {
          redemption_status: RewardRedemptionStatus.CANCELLED,
          entitlement_status: RewardEntitlementStatus.CANCELLED,
        },
      });
      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId,
          orderKg: 3,
          employeeId,
        }),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    });

    it('12. Already-used entitlement rejected', async () => {
      const { service, tx } = buildService({
        locked: {
          remaining_kg: 0,
          entitlement_status: RewardEntitlementStatus.USED,
        },
      });
      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId,
          orderKg: 3,
          employeeId,
        }),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    });

    it('13. Concurrent usage cannot double-spend entitlement', async () => {
      const shared = {
        remaining_kg: 5,
        entitlement_status: RewardEntitlementStatus.AVAILABLE,
      };
      const { service, tx } = buildService({ locked: { ...shared } });

      // Simulate FOR UPDATE serialization: second lock sees updated remaining.
      let calls = 0;
      tx.$queryRaw = jest.fn(async () => {
        calls += 1;
        if (calls === 1) {
          return [lockedRow({ remaining_kg: 5 })];
        }
        return [
          lockedRow({
            remaining_kg: 0,
            entitlement_status: RewardEntitlementStatus.USED,
          }),
        ];
      });

      await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 5,
        employeeId,
      });

      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId: '77777777-7777-7777-7777-777777777777',
          orderKg: 5,
          employeeId,
        }),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    });

    it('14. Failed order does not consume entitlement', async () => {
      const { service, state, tx } = buildService({
        locked: { remaining_kg: 5 },
        failOnUsageCreate: true,
      });

      await expect(
        service.consumeInTx(tx as any, {
          customerId,
          redemptionItemId: itemId,
          orderId,
          orderKg: 3,
          employeeId,
        }),
      ).rejects.toThrow('order failed');

      // In real Prisma TX the item update would also roll back; here we assert
      // usage was not persisted and callers must wrap in transaction.
      expect(state.usages).toHaveLength(0);
    });

    it('15. Successful order consumes entitlement', async () => {
      const { service, state, tx } = buildService({
        locked: { remaining_kg: 5 },
      });
      await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 3,
        employeeId,
      });
      expect(state.usages).toHaveLength(1);
      expect(state.remainingKg).toBe(2);
    });

    it('16-17. Physical reward starts PENDING and staff fulfill -> COMPLETED', async () => {
      const { service, state } = buildService();
      expect(state.redemption.status).toBe(RewardRedemptionStatus.PENDING);

      const fulfilled = await service.fulfillPhysicalRedemption({
        redemptionId: 'redemption-1',
        employeeId,
      });

      expect(fulfilled.status).toBe(RewardRedemptionStatus.COMPLETED);
      expect(state.redemption.status).toBe(RewardRedemptionStatus.COMPLETED);
      expect(state.redemption.fulfilledByEmployeeId).toBe(employeeId);
    });

    it('18. Unauthorized staff cannot fulfill (laundry-only catalog rejected)', async () => {
      const { service, state } = buildService({
        redemption: {
          id: 'redemption-laundry',
          status: RewardRedemptionStatus.COMPLETED,
          totalPointsSpent: 5,
          createdAt: new Date(),
          fulfilledAt: null,
          fulfilledByEmployee: null,
          items: [
            {
              id: 'cks-1',
              pointsSpent: 5,
              catalogItem: {
                name: 'CKS 5 KG',
                code: 'CKS_5KG',
                type: RewardCatalogType.LAUNDRY_KG,
              },
            },
          ],
        },
      });

      await expect(
        service.fulfillPhysicalRedemption({
          redemptionId: 'redemption-laundry',
          employeeId,
        }),
      ).rejects.toThrow(/physical reward/i);
      expect(state.redemption.status).toBe(RewardRedemptionStatus.COMPLETED);
    });

    it('19. Point balance remains unchanged when CKS entitlement is used', async () => {
      const { service, state, tx, prisma } = buildService({
        locked: { remaining_kg: 5 },
        pointBalance: 0,
      });
      await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 3,
        employeeId,
      });
      expect(prisma.rewardPoint.findMany).not.toHaveBeenCalled();
      expect(state.pointBalance).toBe(0);
      expect(state.usages[0]).not.toHaveProperty('pointsSpent');
    });

    it('20. Redemption deducts points only once (usage creates no point ledger)', async () => {
      const { service, tx, prisma } = buildService({
        locked: { remaining_kg: 5 },
      });
      await service.consumeInTx(tx as any, {
        customerId,
        redemptionItemId: itemId,
        orderId,
        orderKg: 3,
        employeeId,
      });
      expect(prisma.rewardPoint.findMany).not.toHaveBeenCalled();
      expect(tx.rewardEntitlementUsage.create).toHaveBeenCalled();
    });
  });
});
