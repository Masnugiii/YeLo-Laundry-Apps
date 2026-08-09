import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { toCustomerWalletSummary } from '../customer/customer-wallet.mapper';
import { MembershipService } from './membership.service';

@Injectable()
export class CustomerLoyaltyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletRepository: CustomerWalletRepository,
    private readonly membershipService: MembershipService,
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

    const [rewardSummary, membership, voucherCount, lifetimeSpending] =
      await Promise.all([
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
      ]);

    return {
      walletBalance: wallet
        ? toCustomerWalletSummary(wallet, aggregates).balance
        : 0,
      totalTopup: aggregates.totalTopup,
      totalSpending: aggregates.totalSpending,
      totalRefund: 0,
      rewardPoint: rewardSummary,
      membership,
      voucherCount,
      lastTopup: lastTopup
        ? { amount: Number(lastTopup.amount), date: lastTopup.createdAt }
        : null,
      lifetimeSpending: Number(lifetimeSpending._sum.amount ?? 0),
    };
  }
}
