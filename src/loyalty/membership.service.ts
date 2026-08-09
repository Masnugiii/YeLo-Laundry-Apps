import { Injectable } from '@nestjs/common';
import { RewardPointType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { LoyaltySettingsService } from './loyalty-settings.service';
import {
  MembershipLevel,
  MembershipSummary,
  RewardSummary,
} from './loyalty.types';

@Injectable()
export class MembershipService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settingsService: LoyaltySettingsService,
  ) {}

  async getMembership(customerId: string): Promise<MembershipSummary> {
    const settings = await this.settingsService.getSettings();
    const lifetimePoints = await this.getLifetimePoints(customerId);
    const currentPoints = await this.getCurrentPoints(customerId);
    const levels = [...settings.membershipLevels].sort(
      (a, b) => b.minPoints - a.minPoints,
    );

    const currentLevel =
      levels.find((level) => lifetimePoints >= level.minPoints) ??
      settings.membershipLevels[0];
    const nextLevel = this.getNextLevel(settings.membershipLevels, currentLevel);
    const pointsToNext = nextLevel
      ? Math.max(nextLevel.minPoints - lifetimePoints, 0)
      : 0;
    const progressPercent = nextLevel
      ? Math.min(
          100,
          Math.round(
            ((lifetimePoints - currentLevel.minPoints) /
              Math.max(nextLevel.minPoints - currentLevel.minPoints, 1)) *
              100,
          ),
        )
      : 100;

    return {
      currentLevel,
      nextLevel,
      lifetimePoints,
      currentPoints,
      progressPercent,
      pointsToNext,
    };
  }

  async getRewardSummary(customerId: string): Promise<RewardSummary> {
    const rows = await this.prisma.rewardPoint.findMany({
      where: { customerId, deletedAt: null },
      select: { point: true, type: true },
    });

    let earned = 0;
    let used = 0;
    let expired = 0;

    for (const row of rows) {
      if (row.type === RewardPointType.earn) earned += row.point;
      if (row.type === RewardPointType.redeem) used += Math.abs(row.point);
      if (row.type === RewardPointType.expired) expired += Math.abs(row.point);
    }

    const currentPoint = await this.getCurrentPoints(customerId);

    return {
      currentPoint,
      earned,
      used,
      expired,
      lifetimePoint: earned,
    };
  }

  resolveLevel(
    lifetimePoints: number,
    levels: MembershipLevel[],
  ): MembershipLevel {
    const sorted = [...levels].sort((a, b) => b.minPoints - a.minPoints);
    return sorted.find((level) => lifetimePoints >= level.minPoints) ?? levels[0];
  }

  private getNextLevel(
    levels: MembershipLevel[],
    current: MembershipLevel,
  ): MembershipLevel | null {
    const sorted = [...levels].sort((a, b) => a.minPoints - b.minPoints);
    const index = sorted.findIndex((level) => level.code === current.code);
    return index >= 0 && index < sorted.length - 1 ? sorted[index + 1] : null;
  }

  private async getLifetimePoints(customerId: string): Promise<number> {
    const aggregate = await this.prisma.rewardPoint.aggregate({
      where: {
        customerId,
        deletedAt: null,
        type: RewardPointType.earn,
      },
      _sum: { point: true },
    });
    return aggregate._sum.point ?? 0;
  }

  private async getCurrentPoints(customerId: string): Promise<number> {
    const now = new Date();
    const rows = await this.prisma.rewardPoint.findMany({
      where: {
        customerId,
        deletedAt: null,
        OR: [{ expiredAt: null }, { expiredAt: { gt: now } }],
      },
      select: { point: true },
    });
    return rows.reduce((sum, row) => sum + row.point, 0);
  }
}
