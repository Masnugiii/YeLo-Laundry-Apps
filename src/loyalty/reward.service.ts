import { Injectable } from '@nestjs/common';
import {
  Prisma,
  RewardPointSource,
  RewardPointType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  buildPointExpirationDate,
  calculateDepositPoints,
  calculateLaundryPaymentPoints,
  resolveDepositPointRule,
  resolveLaundryPointRule,
} from './loyalty-earning.rules';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { MembershipService } from './membership.service';

interface AddPointsInput {
  customerId: string;
  point: number;
  source: RewardPointSource;
  type?: RewardPointType;
  description?: string;
  referenceType?: string;
  referenceId?: string;
  employeeId?: string;
  expiredAt?: Date;
  remainingPoint?: number | null;
  tx?: Prisma.TransactionClient;
}

interface RewardHistoryQuery {
  page?: number;
  limit?: number;
  customerId?: string;
  source?: RewardPointSource;
  dateFrom?: Date;
  dateTo?: Date;
}

@Injectable()
export class RewardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settingsService: LoyaltySettingsService,
    private readonly membershipService: MembershipService,
  ) {}

  async getSummary(customerId: string) {
    return this.membershipService.getRewardSummary(customerId);
  }

  async getHistory(query: RewardHistoryQuery) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 25;
    const where: Prisma.RewardPointWhereInput = {
      deletedAt: null,
      ...(query.customerId ? { customerId: query.customerId } : {}),
      ...(query.source ? { source: query.source } : {}),
      ...(query.dateFrom || query.dateTo
        ? {
            createdAt: {
              ...(query.dateFrom ? { gte: query.dateFrom } : {}),
              ...(query.dateTo ? { lte: query.dateTo } : {}),
            },
          }
        : {}),
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.rewardPoint.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          createdByEmployee: {
            select: { id: true, fullName: true, employeeCode: true },
          },
        },
      }),
      this.prisma.rewardPoint.count({ where }),
    ]);

    return {
      items: items.map((item) => ({
        id: item.id,
        customerId: item.customerId,
        activity: item.source ?? item.type,
        activityLabel: this.toActivityLabel(item.source, item.type, item.description),
        point: item.point,
        balance: item.balanceAfter,
        reference: item.referenceId,
        referenceType: item.referenceType,
        description: item.description,
        employee: item.createdByEmployee,
        createdAt: item.createdAt,
      })),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  private toActivityLabel(
    source: RewardPointSource | null,
    type: RewardPointType,
    description: string | null,
  ): string {
    if (type === RewardPointType.expired) {
      return 'Point Kedaluwarsa';
    }
    if (type === RewardPointType.clawback) {
      return 'Pembatalan Point';
    }
    if (type === RewardPointType.redeem || source === RewardPointSource.redeem) {
      return 'Penukaran Reward';
    }
    if (source === RewardPointSource.laundry_payment) {
      return 'Pembayaran Laundry';
    }
    if (source === RewardPointSource.deposit) {
      return 'Deposit Saldo';
    }
    if (source === RewardPointSource.mission) {
      return 'Misi Reward';
    }
    if (source === RewardPointSource.manual_bonus) {
      return 'Bonus Manual';
    }
    if (description?.trim()) {
      return description.trim();
    }
    return 'YeLo Point';
  }

  async addPoints(input: AddPointsInput) {
    const db = input.tx ?? this.prisma;
    const type =
      input.type ??
      (input.point >= 0 ? RewardPointType.earn : RewardPointType.redeem);
    const isEarnLot = type === RewardPointType.earn && input.point > 0;
    const currentBalance = await this.getCurrentBalance(
      input.customerId,
      input.tx,
    );
    const balanceAfter = currentBalance + input.point;

    try {
      return await db.rewardPoint.create({
        data: {
          customerId: input.customerId,
          point: input.point,
          remainingPoint: isEarnLot
            ? (input.remainingPoint ?? input.point)
            : input.remainingPoint ?? null,
          type,
          source: input.source,
          description: input.description,
          referenceType: input.referenceType,
          referenceId: input.referenceId,
          balanceAfter,
          expiredAt: input.expiredAt,
          createdByEmployeeId: input.employeeId,
        },
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002' &&
        input.referenceId
      ) {
        const existing = await db.rewardPoint.findFirst({
          where: {
            customerId: input.customerId,
            referenceId: input.referenceId,
            referenceType: input.referenceType,
            source: input.source,
            type,
            deletedAt: null,
          },
        });
        if (existing) {
          return existing;
        }
      }
      throw error;
    }
  }

  /**
   * Earn laundry points from non-wallet eligible payment amount.
   * Formula from LoyaltySettings.laundryPoint (Admin configurable).
   */
  async earnFromPayment(
    customerId: string,
    orderId: string,
    amount: number,
    employeeId?: string,
  ) {
    const settings = await this.settingsService.getSettings();
    const points = calculateLaundryPaymentPoints(
      amount,
      resolveLaundryPointRule(settings),
    );
    if (points <= 0) {
      return null;
    }

    return this.createEarnLot({
      customerId,
      point: points,
      source: RewardPointSource.laundry_payment,
      description: 'Points from laundry payment',
      referenceType: 'ORDER',
      referenceId: orderId,
      employeeId,
    });
  }

  /**
   * Earn deposit points from wallet top-up.
   * Formula from LoyaltySettings.depositPoint (Admin configurable).
   */
  async earnFromDeposit(
    customerId: string,
    depositAmount: number,
    referenceType: string,
    referenceId: string,
    employeeId?: string | null,
    tx?: Prisma.TransactionClient,
  ) {
    const settings = await this.settingsService.getSettings();
    const points = calculateDepositPoints(
      depositAmount,
      resolveDepositPointRule(settings),
    );
    if (points <= 0) {
      return null;
    }

    return this.createEarnLot({
      customerId,
      point: points,
      source: RewardPointSource.deposit,
      description: 'Points from wallet deposit',
      referenceType,
      referenceId,
      employeeId: employeeId ?? undefined,
      tx,
    });
  }

  /**
   * Claw back laundry points for a refunded order.
   * Keeps the original earn row; writes a clawback ledger entry once.
   */
  async clawbackFromOrder(
    customerId: string,
    orderId: string,
    employeeId?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const earn = await tx.rewardPoint.findFirst({
        where: {
          customerId,
          referenceId: orderId,
          referenceType: 'ORDER',
          source: RewardPointSource.laundry_payment,
          type: RewardPointType.earn,
          deletedAt: null,
        },
      });

      if (!earn) {
        return null;
      }

      const existingClawback = await tx.rewardPoint.findFirst({
        where: {
          customerId,
          referenceId: orderId,
          referenceType: 'ORDER',
          source: RewardPointSource.laundry_payment,
          type: RewardPointType.clawback,
          deletedAt: null,
        },
      });

      if (existingClawback) {
        return existingClawback;
      }

      const pointsToClaw = earn.point;
      const remaining = earn.remainingPoint ?? earn.point;
      const consumedFromLot = Math.min(remaining, pointsToClaw);

      if (consumedFromLot > 0) {
        await tx.rewardPoint.update({
          where: { id: earn.id },
          data: { remainingPoint: remaining - consumedFromLot },
        });
      }

      const currentBalance = await this.getCurrentBalance(customerId, tx);

      try {
        const clawback = await tx.rewardPoint.create({
          data: {
            customerId,
            point: -pointsToClaw,
            remainingPoint: null,
            type: RewardPointType.clawback,
            source: RewardPointSource.laundry_payment,
            description: 'Clawback points from refunded order',
            referenceType: 'ORDER',
            referenceId: orderId,
            balanceAfter: currentBalance - pointsToClaw,
            createdByEmployeeId: employeeId,
          },
        });

        if (consumedFromLot > 0) {
          await tx.rewardPointAllocation.create({
            data: {
              earnPointId: earn.id,
              consumePointId: clawback.id,
              points: consumedFromLot,
            },
          });
        }

        return clawback;
      } catch (error) {
        if (
          error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002'
        ) {
          const raced = await tx.rewardPoint.findFirst({
            where: {
              customerId,
              referenceId: orderId,
              referenceType: 'ORDER',
              source: RewardPointSource.laundry_payment,
              type: RewardPointType.clawback,
              deletedAt: null,
            },
          });
          if (raced) {
            return raced;
          }
        }
        throw error;
      }
    });
  }

  async addManualBonus(
    customerId: string,
    point: number,
    description: string,
    employeeId: string,
  ) {
    const settings = await this.settingsService.getSettings();
    const expiredAt = buildPointExpirationDate(settings.pointExpirationDays);

    return this.addPoints({
      customerId,
      point,
      source: RewardPointSource.manual_bonus,
      description,
      employeeId,
      expiredAt,
    });
  }

  private async createEarnLot(input: {
    customerId: string;
    point: number;
    source: RewardPointSource;
    description: string;
    referenceType: string;
    referenceId: string;
    employeeId?: string;
    tx?: Prisma.TransactionClient;
  }) {
    const db = input.tx ?? this.prisma;
    const existing = await db.rewardPoint.findFirst({
      where: {
        customerId: input.customerId,
        referenceId: input.referenceId,
        referenceType: input.referenceType,
        source: input.source,
        type: RewardPointType.earn,
        deletedAt: null,
      },
    });
    if (existing) {
      return existing;
    }

    const settings = await this.settingsService.getSettings();
    const expiredAt = buildPointExpirationDate(settings.pointExpirationDays);

    const write = async (tx: Prisma.TransactionClient) => {
      const raced = await tx.rewardPoint.findFirst({
        where: {
          customerId: input.customerId,
          referenceId: input.referenceId,
          referenceType: input.referenceType,
          source: input.source,
          type: RewardPointType.earn,
          deletedAt: null,
        },
      });
      if (raced) {
        return raced;
      }

      return this.addPoints({
        customerId: input.customerId,
        point: input.point,
        source: input.source,
        description: input.description,
        referenceType: input.referenceType,
        referenceId: input.referenceId,
        employeeId: input.employeeId,
        type: RewardPointType.earn,
        remainingPoint: input.point,
        expiredAt,
        tx,
      });
    };

    if (input.tx) {
      return write(input.tx);
    }

    return this.prisma.$transaction(write);
  }

  private async getCurrentBalance(
    customerId: string,
    tx?: Prisma.TransactionClient,
  ): Promise<number> {
    if (!tx) {
      const summary = await this.membershipService.getRewardSummary(customerId);
      return summary.currentPoint;
    }

    const now = new Date();
    const rows = await tx.rewardPoint.findMany({
      where: {
        customerId,
        deletedAt: null,
        OR: [{ expiredAt: null }, { expiredAt: { gt: now } }],
      },
      select: { point: true, type: true },
    });

    return rows.reduce((sum, row) => {
      if (row.type === RewardPointType.expired) {
        return sum;
      }
      return sum + row.point;
    }, 0);
  }
}
