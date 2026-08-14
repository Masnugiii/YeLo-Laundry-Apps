import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import {
  Prisma,
  RewardCatalogType,
  RewardEntitlementStatus,
  RewardRedemptionStatus,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  CKS_SERVICE_TYPE,
  addDays,
  isUsableEntitlementStatus,
  resolveEntitlementStatus,
  splitEntitlementKg,
} from './reward-entitlement.rules';

type TxClient = Prisma.TransactionClient;

interface LockedEntitlementRow {
  id: string;
  entitlement_kg: number | null;
  remaining_kg: Prisma.Decimal | number | null;
  entitlement_status: RewardEntitlementStatus | null;
  entitlement_expires_at: Date | null;
  customer_id: string;
  redemption_status: RewardRedemptionStatus;
  catalog_type: RewardCatalogType;
  service_type: string | null;
  catalog_name: string;
  points_spent: number;
  redeemed_at: Date;
}

export interface ApplyEntitlementQuote {
  redemptionItemId: string;
  rewardName: string;
  serviceType: string;
  entitlementKg: number;
  remainingKgBefore: number;
  orderKg: number;
  freeKg: number;
  billableKg: number;
  remainingKgAfter: number;
  entitlementStatusAfter: RewardEntitlementStatus;
  expiresAt: Date;
}

@Injectable()
export class RewardEntitlementService {
  constructor(private readonly prisma: PrismaService) {}

  async listCustomerRedemptions(customerId: string) {
    const rows = await this.prisma.rewardRedemption.findMany({
      where: { customerId, deletedAt: null },
      orderBy: { createdAt: 'desc' },
      include: {
        items: {
          include: {
            catalogItem: true,
            usages: {
              orderBy: { createdAt: 'desc' },
              take: 5,
              include: {
                order: { select: { id: true, invoiceNumber: true } },
              },
            },
          },
        },
        fulfilledByEmployee: {
          select: { id: true, fullName: true, employeeCode: true },
        },
      },
    });

    const now = new Date();
    return rows.map((redemption) => ({
      id: redemption.id,
      status: redemption.status,
      totalPointsSpent: redemption.totalPointsSpent,
      createdAt: redemption.createdAt,
      fulfilledAt: redemption.fulfilledAt,
      fulfilledBy: redemption.fulfilledByEmployee,
      items: redemption.items.map((item) => {
        const remainingKg = Number(item.remainingKg ?? item.entitlementKg ?? 0);
        const entitlementKg = item.entitlementKg ?? 0;
        const status =
          item.entitlementKg != null
            ? resolveEntitlementStatus({
                remainingKg,
                entitlementKg,
                expiresAt: item.entitlementExpiresAt,
                currentStatus: item.entitlementStatus,
                now,
              })
            : null;

        return {
          id: item.id,
          rewardName: item.catalogItem.name,
          rewardCode: item.catalogItem.code,
          rewardType: item.catalogItem.type,
          pointsSpent: item.pointsSpent,
          quantity: item.quantity,
          entitlementKg: item.entitlementKg,
          remainingKg: item.entitlementKg != null ? remainingKg : null,
          entitlementStatus: status,
          entitlementExpiresAt: item.entitlementExpiresAt,
          metadata: item.metadata,
          usages: item.usages.map((usage) => ({
            id: usage.id,
            orderId: usage.orderId,
            invoiceNumber: usage.order.invoiceNumber,
            kgConsumed: Number(usage.kgConsumed),
            freeKgApplied: Number(usage.freeKgApplied),
            billableKg: Number(usage.billableKg),
            createdAt: usage.createdAt,
          })),
        };
      }),
    }));
  }

  async listActiveCksEntitlements(customerId: string) {
    await this.expireStaleEntitlements(customerId);

    const rows = await this.prisma.rewardRedemptionItem.findMany({
      where: {
        entitlementKg: { not: null },
        remainingKg: { gt: 0 },
        entitlementStatus: {
          in: [
            RewardEntitlementStatus.AVAILABLE,
            RewardEntitlementStatus.PARTIALLY_USED,
          ],
        },
        entitlementExpiresAt: { gt: new Date() },
        redemption: {
          customerId,
          deletedAt: null,
          status: { not: RewardRedemptionStatus.CANCELLED },
        },
        catalogItem: {
          type: RewardCatalogType.LAUNDRY_KG,
          deletedAt: null,
        },
      },
      orderBy: { entitlementExpiresAt: 'asc' },
      include: {
        catalogItem: true,
        redemption: {
          select: {
            id: true,
            status: true,
            createdAt: true,
            totalPointsSpent: true,
          },
        },
      },
    });

    return rows
      .filter((row) => {
        const serviceType =
          row.catalogItem.serviceType ??
          (row.metadata as { serviceType?: string } | null)?.serviceType ??
          CKS_SERVICE_TYPE;
        return serviceType.toUpperCase() === CKS_SERVICE_TYPE;
      })
      .map((row) => ({
        redemptionItemId: row.id,
        redemptionId: row.redemptionId,
        rewardName: row.catalogItem.name,
        rewardCode: row.catalogItem.code,
        pointsSpent: row.pointsSpent,
        serviceType: CKS_SERVICE_TYPE,
        entitlementKg: row.entitlementKg ?? 0,
        remainingKg: Number(row.remainingKg ?? 0),
        entitlementStatus: row.entitlementStatus,
        redeemedAt: row.redemption.createdAt,
        expiresAt: row.entitlementExpiresAt,
      }));
  }

  async quoteApply(input: {
    customerId: string;
    redemptionItemId: string;
    orderKg: number;
    serviceType?: string;
  }): Promise<ApplyEntitlementQuote> {
    const locked = await this.prisma.$transaction(async (tx) =>
      this.lockAndValidateEntitlement(tx, input),
    );
    return this.toQuote(locked, input.orderKg);
  }

  /**
   * Consume entitlement inside an existing order-create transaction.
   * Uses FOR UPDATE so concurrent applies cannot double-spend.
   */
  async consumeInTx(
    tx: TxClient,
    input: {
      customerId: string;
      redemptionItemId: string;
      orderId: string;
      orderKg: number;
      serviceType?: string;
      employeeId?: string;
      expectedFreeKg?: number;
      expectedBillableKg?: number;
    },
  ): Promise<ApplyEntitlementQuote> {
    const locked = await this.lockAndValidateEntitlement(tx, input);
    const quote = this.toQuote(locked, input.orderKg);

    if (
      input.expectedFreeKg != null &&
      Math.abs(quote.freeKg - input.expectedFreeKg) > 0.0001
    ) {
      throw new UnprocessableEntityException(
        'CKS entitlement changed during order creation; retry the order',
      );
    }

    if (
      input.expectedBillableKg != null &&
      Math.abs(quote.billableKg - input.expectedBillableKg) > 0.0001
    ) {
      throw new UnprocessableEntityException(
        'CKS entitlement changed during order creation; retry the order',
      );
    }

    await tx.rewardRedemptionItem.update({
      where: { id: locked.id },
      data: {
        remainingKg: quote.remainingKgAfter,
        entitlementStatus: quote.entitlementStatusAfter,
      },
    });

    await tx.rewardEntitlementUsage.create({
      data: {
        redemptionItemId: locked.id,
        orderId: input.orderId,
        kgConsumed: quote.freeKg,
        freeKgApplied: quote.freeKg,
        billableKg: quote.billableKg,
        orderKg: quote.orderKg,
        remainingKgAfter: quote.remainingKgAfter,
        appliedByEmployeeId: input.employeeId,
      },
    });

    return quote;
  }

  async fulfillPhysicalRedemption(input: {
    redemptionId: string;
    employeeId: string;
  }) {
    const redemption = await this.prisma.rewardRedemption.findFirst({
      where: { id: input.redemptionId, deletedAt: null },
      include: {
        items: { include: { catalogItem: true } },
        fulfilledByEmployee: {
          select: { id: true, fullName: true, employeeCode: true },
        },
      },
    });

    if (!redemption) {
      throw new NotFoundException('Reward redemption not found');
    }

    const hasPhysical = redemption.items.some(
      (item) => item.catalogItem.type === RewardCatalogType.PHYSICAL_GOODS,
    );

    if (!hasPhysical) {
      throw new BadRequestException(
        'Only physical reward redemptions can be fulfilled',
      );
    }

    if (redemption.status === RewardRedemptionStatus.CANCELLED) {
      throw new UnprocessableEntityException(
        'Cancelled redemption cannot be fulfilled',
      );
    }

    if (redemption.status === RewardRedemptionStatus.COMPLETED) {
      return this.mapFulfillment(redemption);
    }

    if (redemption.status !== RewardRedemptionStatus.PENDING) {
      throw new UnprocessableEntityException(
        `Redemption status ${redemption.status} cannot be fulfilled`,
      );
    }

    const updated = await this.prisma.rewardRedemption.update({
      where: { id: redemption.id },
      data: {
        status: RewardRedemptionStatus.COMPLETED,
        fulfilledByEmployeeId: input.employeeId,
        fulfilledAt: new Date(),
      },
      include: {
        items: { include: { catalogItem: true } },
        fulfilledByEmployee: {
          select: { id: true, fullName: true, employeeCode: true },
        },
      },
    });

    return this.mapFulfillment(updated);
  }

  async expireStaleEntitlements(customerId?: string) {
    const now = new Date();
    await this.prisma.rewardRedemptionItem.updateMany({
      where: {
        entitlementKg: { not: null },
        remainingKg: { gt: 0 },
        entitlementExpiresAt: { lte: now },
        entitlementStatus: {
          in: [
            RewardEntitlementStatus.AVAILABLE,
            RewardEntitlementStatus.PARTIALLY_USED,
          ],
        },
        ...(customerId
          ? { redemption: { customerId, deletedAt: null } }
          : {}),
      },
      data: { entitlementStatus: RewardEntitlementStatus.EXPIRED },
    });
  }

  buildEntitlementCreateFields(input: {
    entitlementKg: number | null;
    durationDays: number;
    issuedAt?: Date;
  }): {
    remainingKg: number | null;
    entitlementStatus: RewardEntitlementStatus | null;
    entitlementExpiresAt: Date | null;
  } {
    if (input.entitlementKg == null) {
      return {
        remainingKg: null,
        entitlementStatus: null,
        entitlementExpiresAt: null,
      };
    }

    const issuedAt = input.issuedAt ?? new Date();
    return {
      remainingKg: input.entitlementKg,
      entitlementStatus: RewardEntitlementStatus.AVAILABLE,
      entitlementExpiresAt: addDays(issuedAt, input.durationDays),
    };
  }

  private async lockAndValidateEntitlement(
    tx: TxClient,
    input: {
      customerId: string;
      redemptionItemId: string;
      orderKg: number;
      serviceType?: string;
    },
  ): Promise<LockedEntitlementRow> {
    if (input.orderKg <= 0) {
      throw new BadRequestException('Order KG must be greater than zero');
    }

    const rows = await tx.$queryRaw<LockedEntitlementRow[]>`
      SELECT
        item.id,
        item.entitlement_kg,
        item.remaining_kg,
        item.entitlement_status,
        item.entitlement_expires_at,
        redemption.customer_id,
        redemption.status AS redemption_status,
        catalog.type AS catalog_type,
        catalog.service_type,
        catalog.name AS catalog_name,
        item.points_spent,
        redemption.created_at AS redeemed_at
      FROM reward_redemption_items item
      INNER JOIN reward_redemptions redemption
        ON redemption.id = item.redemption_id
      INNER JOIN reward_catalog_items catalog
        ON catalog.id = item.catalog_item_id
      WHERE item.id = ${input.redemptionItemId}::uuid
        AND redemption.deleted_at IS NULL
        AND catalog.deleted_at IS NULL
      FOR UPDATE OF item
    `;

    const locked = rows[0];
    if (!locked) {
      throw new NotFoundException('CKS entitlement not found');
    }

    if (locked.customer_id !== input.customerId) {
      throw new ForbiddenException(
        'Entitlement does not belong to this customer',
      );
    }

    if (locked.redemption_status === RewardRedemptionStatus.CANCELLED) {
      throw new UnprocessableEntityException(
        'Cancelled entitlement cannot be applied',
      );
    }

    if (locked.catalog_type !== RewardCatalogType.LAUNDRY_KG) {
      throw new BadRequestException('Entitlement is not a laundry KG reward');
    }

    const serviceType = (
      locked.service_type ??
      input.serviceType ??
      CKS_SERVICE_TYPE
    ).toUpperCase();

    if (serviceType !== CKS_SERVICE_TYPE) {
      throw new BadRequestException('Entitlement service type must be CKS');
    }

    if (
      input.serviceType &&
      input.serviceType.toUpperCase() !== CKS_SERVICE_TYPE
    ) {
      throw new BadRequestException(
        'CKS entitlement can only be applied to CKS laundry service',
      );
    }

    const entitlementKg = Number(locked.entitlement_kg ?? 0);
    const remainingKg = Number(locked.remaining_kg ?? 0);
    const status = resolveEntitlementStatus({
      remainingKg,
      entitlementKg,
      expiresAt: locked.entitlement_expires_at,
      currentStatus: locked.entitlement_status,
    });

    if (status === RewardEntitlementStatus.CANCELLED) {
      throw new UnprocessableEntityException(
        'Cancelled entitlement cannot be applied',
      );
    }

    if (status === RewardEntitlementStatus.EXPIRED) {
      if (locked.entitlement_status !== RewardEntitlementStatus.EXPIRED) {
        await tx.rewardRedemptionItem.update({
          where: { id: locked.id },
          data: { entitlementStatus: RewardEntitlementStatus.EXPIRED },
        });
      }
      throw new UnprocessableEntityException(
        'Entitlement has expired and cannot be applied',
      );
    }

    if (status === RewardEntitlementStatus.USED || remainingKg <= 0) {
      throw new UnprocessableEntityException(
        'Entitlement has already been fully used',
      );
    }

    if (!isUsableEntitlementStatus(status)) {
      throw new UnprocessableEntityException(
        `Entitlement status ${status} cannot be applied`,
      );
    }

    return locked;
  }

  private toQuote(
    locked: LockedEntitlementRow,
    orderKg: number,
  ): ApplyEntitlementQuote {
    const entitlementKg = Number(locked.entitlement_kg ?? 0);
    const remainingKgBefore = Number(locked.remaining_kg ?? 0);
    const split = splitEntitlementKg(remainingKgBefore, orderKg);
    const entitlementStatusAfter = resolveEntitlementStatus({
      remainingKg: split.remainingKgAfter,
      entitlementKg,
      expiresAt: locked.entitlement_expires_at,
      currentStatus: locked.entitlement_status,
    });

    return {
      redemptionItemId: locked.id,
      rewardName: locked.catalog_name,
      serviceType: CKS_SERVICE_TYPE,
      entitlementKg,
      remainingKgBefore,
      orderKg: split.orderKg,
      freeKg: split.freeKg,
      billableKg: split.billableKg,
      remainingKgAfter: split.remainingKgAfter,
      entitlementStatusAfter,
      expiresAt: locked.entitlement_expires_at!,
    };
  }

  private mapFulfillment(redemption: {
    id: string;
    status: RewardRedemptionStatus;
    totalPointsSpent: number;
    createdAt: Date;
    fulfilledAt: Date | null;
    fulfilledByEmployee: {
      id: string;
      fullName: string;
      employeeCode: string;
    } | null;
    items: Array<{
      id: string;
      pointsSpent: number;
      catalogItem: { name: string; code: string; type: RewardCatalogType };
    }>;
  }) {
    return {
      id: redemption.id,
      status: redemption.status,
      totalPointsSpent: redemption.totalPointsSpent,
      createdAt: redemption.createdAt,
      fulfilledAt: redemption.fulfilledAt,
      fulfilledBy: redemption.fulfilledByEmployee,
      items: redemption.items.map((item) => ({
        id: item.id,
        rewardName: item.catalogItem.name,
        rewardCode: item.catalogItem.code,
        rewardType: item.catalogItem.type,
        pointsSpent: item.pointsSpent,
      })),
    };
  }
}
