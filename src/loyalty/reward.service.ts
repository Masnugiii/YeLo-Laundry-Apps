import { Injectable } from '@nestjs/common';
import {
  Prisma,
  RewardPointSource,
  RewardPointType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { MembershipService } from './membership.service';

interface AddPointsInput {
  customerId: string;
  point: number;
  source: RewardPointSource;
  description?: string;
  referenceType?: string;
  referenceId?: string;
  employeeId?: string;
  expiredAt?: Date;
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

  async addPoints(input: AddPointsInput) {
    const currentBalance = await this.getCurrentBalance(input.customerId);
    const balanceAfter = currentBalance + input.point;

    return this.prisma.rewardPoint.create({
      data: {
        customerId: input.customerId,
        point: input.point,
        type: input.point >= 0 ? RewardPointType.earn : RewardPointType.redeem,
        source: input.source,
        description: input.description,
        referenceType: input.referenceType,
        referenceId: input.referenceId,
        balanceAfter,
        expiredAt: input.expiredAt,
        createdByEmployeeId: input.employeeId,
      },
    });
  }

  async earnFromPayment(
    customerId: string,
    orderId: string,
    amount: number,
    employeeId?: string,
  ) {
    const existing = await this.prisma.rewardPoint.findFirst({
      where: {
        customerId,
        referenceId: orderId,
        referenceType: 'ORDER',
        source: RewardPointSource.laundry_payment,
        deletedAt: null,
      },
    });
    if (existing) return existing;

    const settings = await this.settingsService.getSettings();
    const points = Math.floor(amount / settings.rupiahPerPoint) * settings.pointPerRupiah;
    if (points <= 0) return null;

    const expiredAt = new Date();
    expiredAt.setDate(expiredAt.getDate() + settings.pointExpirationDays);

    return this.addPoints({
      customerId,
      point: points,
      source: RewardPointSource.laundry_payment,
      description: `Points from laundry payment`,
      referenceType: 'ORDER',
      referenceId: orderId,
      employeeId,
      expiredAt,
    });
  }

  async addManualBonus(
    customerId: string,
    point: number,
    description: string,
    employeeId: string,
  ) {
    const settings = await this.settingsService.getSettings();
    const expiredAt = new Date();
    expiredAt.setDate(expiredAt.getDate() + settings.pointExpirationDays);

    return this.addPoints({
      customerId,
      point,
      source: RewardPointSource.manual_bonus,
      description,
      employeeId,
      expiredAt,
    });
  }

  private async getCurrentBalance(customerId: string): Promise<number> {
    const summary = await this.membershipService.getRewardSummary(customerId);
    return summary.currentPoint;
  }
}
