import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { toCustomerWalletSummary } from '../customer/customer-wallet.mapper';
import { MembershipService } from './membership.service';
import { RewardEntitlementService } from './reward-entitlement.service';
import { RewardRedeemService } from './reward-redeem.service';
import { RewardService } from './reward.service';

@Injectable()
export class CustomerLoyaltyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletRepository: CustomerWalletRepository,
    private readonly membershipService: MembershipService,
    private readonly rewardEntitlementService: RewardEntitlementService,
    private readonly rewardRedeemService: RewardRedeemService,
    private readonly rewardService: RewardService,
  ) {}

  async getCustomerLoyalty(customerId: string) {
    const wallet = await this.walletRepository.findWalletByCustomerId(customerId);
    const aggregates = wallet
      ? await this.walletRepository.getWalletAggregates(customerId, wallet.id)
      : { totalTopup: 0, totalCashback: 0, totalSpending: 0 };

    const lastTopup = await this.prisma.walletTransaction.findFirst({
      where: { customerId, deletedAt: null, type: 'top_up' },
      orderBy: { createdAt: 'desc' },
      select: { createdAt: true, amount: true },
    });

    const [
      rewardSummary,
      membership,
      voucherCount,
      lifetimeSpending,
      activeEntitlements,
      redemptions,
    ] = await Promise.all([
      this.membershipService.getRewardSummary(customerId),
      this.membershipService.getMembership(customerId),
      this.prisma.loyaltyVoucher.count({
        where: { deletedAt: null, status: 'ACTIVE' },
      }),
      this.prisma.payment.aggregate({
        where: {
          order: { customerId, deletedAt: null, orderStatus: 'COMPLETED' },
          deletedAt: null,
          paymentStatus: 'PAID',
        },
        _sum: { amount: true },
      }),
      this.rewardEntitlementService.listActiveCksEntitlements(customerId),
      this.rewardEntitlementService.listCustomerRedemptions(customerId),
    ]);

    return {
      walletBalance: wallet
        ? toCustomerWalletSummary(wallet, aggregates).balance
        : 0,
      totalTopup: aggregates.totalTopup,
      totalSpending: aggregates.totalSpending,
      totalRefund: 0,
      rewardPoint: rewardSummary,
      yeloRewards: {
        currentPoint: rewardSummary.currentPoint,
        earned: rewardSummary.earned,
        redeemed: rewardSummary.redeemed,
        expired: rewardSummary.expired,
        clawback: rewardSummary.clawback,
      },
      membership,
      voucherCount,
      activeCksEntitlements: activeEntitlements,
      rewardRedemptions: redemptions,
      lastTopup: lastTopup
        ? { amount: Number(lastTopup.amount), date: lastTopup.createdAt }
        : null,
      lifetimeSpending: Number(lifetimeSpending._sum.amount ?? 0),
    };
  }

  getPointHistory(customerId: string, query: { page?: number; limit?: number }) {
    return this.rewardService.getHistory({
      customerId,
      page: query.page,
      limit: query.limit,
    });
  }

  listRedemptions(customerId: string) {
    return this.rewardEntitlementService.listCustomerRedemptions(customerId);
  }

  listActiveEntitlements(customerId: string) {
    return this.rewardEntitlementService.listActiveCksEntitlements(customerId);
  }

  listRewardCatalog() {
    return this.rewardRedeemService.listCatalog({ activeOnly: true });
  }

  previewEntitlement(input: {
    customerId: string;
    redemptionItemId: string;
    orderKg: number;
    serviceType?: string;
  }) {
    return this.rewardEntitlementService.quoteApply(input);
  }

  fulfillRedemption(redemptionId: string, employeeId: string) {
    return this.rewardEntitlementService.fulfillPhysicalRedemption({
      redemptionId,
      employeeId,
    });
  }
}
