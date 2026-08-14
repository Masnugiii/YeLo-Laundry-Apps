import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import {
  Prisma,
  RewardCatalogType,
  RewardEntitlementStatus,
  RewardPointSource,
  RewardPointType,
  RewardRedemptionStatus,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { POINT_REWARD_VALUE_IDR } from './reward-catalog.constants';
import { planFifoConsumption, sumAvailablePoints } from './reward-fifo';
import { addDays } from './reward-entitlement.rules';

export interface RedeemItemInput {
  catalogItemId: string;
  quantity: number;
}

export interface RedeemRewardsInput {
  customerId: string;
  items: RedeemItemInput[];
  idempotencyKey?: string;
}

type LockedEarnLot = {
  id: string;
  remaining_point: number | null;
  expired_at: Date | null;
  created_at: Date;
};

@Injectable()
export class RewardRedeemService {
  constructor(private readonly prisma: PrismaService) {}

  async listCatalog(options?: { activeOnly?: boolean }) {
    const activeOnly = options?.activeOnly ?? true;
    const items = await this.prisma.rewardCatalogItem.findMany({
      where: {
        deletedAt: null,
        ...(activeOnly ? { isActive: true } : {}),
      },
      orderBy: [{ costPoints: 'asc' }, { name: 'asc' }],
    });

    return items.map((item) => this.mapCatalogItem(item));
  }

  async getCatalogItem(id: string, options?: { activeOnly?: boolean }) {
    const item = await this.prisma.rewardCatalogItem.findFirst({
      where: {
        id,
        deletedAt: null,
        ...(options?.activeOnly === false ? {} : { isActive: true }),
      },
    });
    if (!item) {
      throw new NotFoundException('Reward not found');
    }
    return this.mapCatalogItem(item);
  }

  async listRedemptions(
    customerId: string,
    query: { page?: number; limit?: number },
  ) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const where: Prisma.RewardRedemptionWhereInput = {
      customerId,
      deletedAt: null,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.rewardRedemption.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          items: {
            include: {
              catalogItem: true,
            },
          },
        },
      }),
      this.prisma.rewardRedemption.count({ where }),
    ]);

    return {
      items: items.map((item) => this.mapRedemption(item)),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  async getRedemption(customerId: string, redemptionId: string) {
    const redemption = await this.prisma.rewardRedemption.findFirst({
      where: {
        id: redemptionId,
        customerId,
        deletedAt: null,
      },
      include: {
        items: {
          include: {
            catalogItem: true,
          },
        },
      },
    });

    if (!redemption) {
      throw new NotFoundException('Redemption not found');
    }

    return this.mapRedemption(redemption);
  }

  async getAvailableBalance(customerId: string): Promise<number> {
    const lots = await this.loadActiveEarnLots(this.prisma, customerId, false);
    return sumAvailablePoints(
      lots.map((lot) => ({
        remainingPoint: Number(lot.remaining_point ?? 0),
      })),
    );
  }

  async redeem(input: RedeemRewardsInput) {
    if (!input.items?.length) {
      throw new BadRequestException('At least one reward item is required');
    }

    for (const item of input.items) {
      if (!Number.isInteger(item.quantity) || item.quantity < 1) {
        throw new BadRequestException('Quantity must be a positive integer');
      }
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        if (input.idempotencyKey) {
          const existing = await tx.rewardRedemption.findFirst({
            where: {
              customerId: input.customerId,
              idempotencyKey: input.idempotencyKey,
              deletedAt: null,
            },
            include: {
              items: { include: { catalogItem: true } },
            },
          });
          if (existing) {
            return this.mapRedemption(existing);
          }
        }

        const catalogIds = [...new Set(input.items.map((i) => i.catalogItemId))];
        const catalogItems = await tx.rewardCatalogItem.findMany({
          where: {
            id: { in: catalogIds },
            deletedAt: null,
          },
        });

        if (catalogItems.length !== catalogIds.length) {
          throw new NotFoundException('One or more rewards were not found');
        }

        const catalogById = new Map(catalogItems.map((item) => [item.id, item]));
        let totalPointsSpent = 0;
        const lineItems: Array<{
          catalogItemId: string;
          quantity: number;
          pointsSpent: number;
          entitlementKg: number | null;
          metadata: Prisma.InputJsonValue | undefined;
          type: RewardCatalogType;
        }> = [];

        for (const requested of input.items) {
          const catalog = catalogById.get(requested.catalogItemId);
          if (!catalog) {
            throw new NotFoundException('Reward not found');
          }
          if (!catalog.isActive) {
            throw new UnprocessableEntityException(
              `Reward "${catalog.name}" is inactive and cannot be redeemed`,
            );
          }
          if (
            catalog.stock !== null &&
            catalog.stock !== undefined &&
            catalog.stock < requested.quantity
          ) {
            throw new UnprocessableEntityException(
              `Reward "${catalog.name}" is out of stock`,
            );
          }

          const pointsSpent = catalog.costPoints * requested.quantity;
          totalPointsSpent += pointsSpent;

          const entitlementKg =
            catalog.type === RewardCatalogType.LAUNDRY_KG
              ? (catalog.kg ?? 0) * requested.quantity
              : null;

          lineItems.push({
            catalogItemId: catalog.id,
            quantity: requested.quantity,
            pointsSpent,
            entitlementKg,
            type: catalog.type,
            metadata:
              catalog.type === RewardCatalogType.LAUNDRY_KG
                ? {
                    serviceType: catalog.serviceType ?? 'CKS',
                    serviceName: 'Cuci Kering Setrika',
                    freeKg: entitlementKg,
                    durationDays: catalog.serviceDurationDays ?? 3,
                    perUnitKg: catalog.kg,
                    quantity: requested.quantity,
                  }
                : {
                    type: catalog.type,
                    name: catalog.name,
                    quantity: requested.quantity,
                  },
          });
        }

        const lockedLots = await this.loadActiveEarnLots(
          tx,
          input.customerId,
          true,
        );
        const available = sumAvailablePoints(
          lockedLots.map((lot) => ({
            remainingPoint: Number(lot.remaining_point ?? 0),
          })),
        );

        if (available < totalPointsSpent) {
          throw new UnprocessableEntityException(
            'Insufficient reward points for this redemption',
          );
        }

        const hasPhysical = lineItems.some(
          (line) => line.type === RewardCatalogType.PHYSICAL_GOODS,
        );
        const status = hasPhysical
          ? RewardRedemptionStatus.PENDING
          : RewardRedemptionStatus.COMPLETED;

        const redemption = await tx.rewardRedemption.create({
          data: {
            customerId: input.customerId,
            status,
            totalPointsSpent,
            idempotencyKey: input.idempotencyKey,
            items: {
              create: lineItems.map((line) => {
                const durationDays =
                  Number(
                    (line.metadata as { durationDays?: number } | undefined)
                      ?.durationDays,
                  ) || 3;
                const entitlementFields =
                  line.entitlementKg != null
                    ? {
                        remainingKg: line.entitlementKg,
                        entitlementStatus: RewardEntitlementStatus.AVAILABLE,
                        entitlementExpiresAt: addDays(new Date(), durationDays),
                      }
                    : {
                        remainingKg: null,
                        entitlementStatus: null,
                        entitlementExpiresAt: null,
                      };

                return {
                  catalogItemId: line.catalogItemId,
                  quantity: line.quantity,
                  pointsSpent: line.pointsSpent,
                  entitlementKg: line.entitlementKg,
                  ...entitlementFields,
                  metadata: line.metadata,
                };
              }),
            },
          },
          include: {
            items: { include: { catalogItem: true } },
          },
        });

        const fifoPlan = planFifoConsumption(
          lockedLots.map((lot) => ({
            id: lot.id,
            remainingPoint: Number(lot.remaining_point ?? 0),
          })),
          totalPointsSpent,
        );

        const balanceAfter = available - totalPointsSpent;
        const ledger = await tx.rewardPoint.create({
          data: {
            customerId: input.customerId,
            point: -totalPointsSpent,
            remainingPoint: null,
            type: RewardPointType.redeem,
            source: RewardPointSource.redeem,
            description: 'YeLo Rewards redemption',
            referenceType: 'REWARD_REDEMPTION',
            referenceId: redemption.id,
            balanceAfter,
          },
        });

        for (const step of fifoPlan) {
          const lot = lockedLots.find((row) => row.id === step.earnPointId);
          const currentRemaining = Number(lot?.remaining_point ?? 0);
          const nextRemaining = currentRemaining - step.points;
          if (nextRemaining < 0) {
            throw new UnprocessableEntityException(
              'Insufficient reward points for this redemption',
            );
          }

          await tx.rewardPoint.update({
            where: { id: step.earnPointId },
            data: { remainingPoint: nextRemaining },
          });

          await tx.rewardPointAllocation.create({
            data: {
              earnPointId: step.earnPointId,
              consumePointId: ledger.id,
              points: step.points,
            },
          });
        }

        for (const line of lineItems) {
          const catalog = catalogById.get(line.catalogItemId);
          if (
            catalog &&
            catalog.stock !== null &&
            catalog.stock !== undefined
          ) {
            await tx.rewardCatalogItem.update({
              where: { id: catalog.id },
              data: { stock: { decrement: line.quantity } },
            });
          }
        }

        const updated = await tx.rewardRedemption.update({
          where: { id: redemption.id },
          data: { ledgerPointId: ledger.id },
          include: {
            items: { include: { catalogItem: true } },
          },
        });

        return this.mapRedemption(updated);
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002' &&
        input.idempotencyKey
      ) {
        const existing = await this.prisma.rewardRedemption.findFirst({
          where: {
            customerId: input.customerId,
            idempotencyKey: input.idempotencyKey,
            deletedAt: null,
          },
          include: {
            items: { include: { catalogItem: true } },
          },
        });
        if (existing) {
          return this.mapRedemption(existing);
        }
      }
      throw error;
    }
  }

  private async loadActiveEarnLots(
    db: Prisma.TransactionClient | PrismaService,
    customerId: string,
    forUpdate: boolean,
  ): Promise<LockedEarnLot[]> {
    if (forUpdate) {
      return db.$queryRaw<LockedEarnLot[]>`
        SELECT id, remaining_point, expired_at, created_at
        FROM reward_points
        WHERE customer_id = ${customerId}::uuid
          AND deleted_at IS NULL
          AND type = 'earn'::reward_point_type
          AND COALESCE(remaining_point, 0) > 0
          AND (expired_at IS NULL OR expired_at > NOW())
        ORDER BY expired_at ASC NULLS LAST, created_at ASC
        FOR UPDATE
      `;
    }

    return db.$queryRaw<LockedEarnLot[]>`
      SELECT id, remaining_point, expired_at, created_at
      FROM reward_points
      WHERE customer_id = ${customerId}::uuid
        AND deleted_at IS NULL
        AND type = 'earn'::reward_point_type
        AND COALESCE(remaining_point, 0) > 0
        AND (expired_at IS NULL OR expired_at > NOW())
      ORDER BY expired_at ASC NULLS LAST, created_at ASC
    `;
  }

  private mapCatalogItem(item: {
    id: string;
    code: string;
    name: string;
    description: string | null;
    type: RewardCatalogType;
    costPoints: number;
    isActive: boolean;
    kg: number | null;
    serviceType: string | null;
    serviceDurationDays: number | null;
    stock: number | null;
    metadata: Prisma.JsonValue;
  }) {
    return {
      id: item.id,
      code: item.code,
      name: item.name,
      description: item.description,
      type: item.type,
      costPoints: item.costPoints,
      isActive: item.isActive,
      kg: item.kg,
      entitlementKg: item.kg,
      serviceType: item.serviceType,
      serviceDurationDays: item.serviceDurationDays,
      durationDays: item.serviceDurationDays,
      stock: item.stock,
      metadata: item.metadata,
      /**
       * Reward reference value only — points are not cash.
       * Do not confuse with laundry earn rate (Rp50.000 / point).
       */
      pointRewardValueIdr: POINT_REWARD_VALUE_IDR,
    };
  }

  private mapRedemption(redemption: {
    id: string;
    customerId: string;
    status: RewardRedemptionStatus;
    totalPointsSpent: number;
    idempotencyKey?: string | null;
    notes: string | null;
    fulfilledAt: Date | null;
    createdAt: Date;
    updatedAt: Date;
    items: Array<{
      id: string;
      catalogItemId: string;
      quantity: number;
      pointsSpent: number;
      entitlementKg: number | null;
      metadata: Prisma.JsonValue;
      catalogItem: {
        id: string;
        code: string;
        name: string;
        type: RewardCatalogType;
        costPoints: number;
        kg: number | null;
        serviceType: string | null;
        serviceDurationDays: number | null;
      };
    }>;
  }) {
    return {
      id: redemption.id,
      customerId: redemption.customerId,
      status: redemption.status,
      totalPointsSpent: redemption.totalPointsSpent,
      idempotencyKey: redemption.idempotencyKey ?? null,
      notes: redemption.notes,
      fulfilledAt: redemption.fulfilledAt,
      createdAt: redemption.createdAt,
      updatedAt: redemption.updatedAt,
      items: redemption.items.map((item) => ({
        id: item.id,
        catalogItemId: item.catalogItemId,
        quantity: item.quantity,
        pointsSpent: item.pointsSpent,
        entitlementKg: item.entitlementKg,
        metadata: item.metadata,
        reward: {
          id: item.catalogItem.id,
          code: item.catalogItem.code,
          name: item.catalogItem.name,
          type: item.catalogItem.type,
          costPoints: item.catalogItem.costPoints,
          kg: item.catalogItem.kg,
          serviceType: item.catalogItem.serviceType,
          serviceDurationDays: item.catalogItem.serviceDurationDays,
        },
      })),
    };
  }
}
