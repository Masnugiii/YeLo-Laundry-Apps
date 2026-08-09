import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { MembershipService } from './membership.service';

@Injectable()
export class LoyaltyReportService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly membershipService: MembershipService,
  ) {}

  async getReport(reportType?: string) {
    switch (reportType) {
      case 'reward':
        return this.getRewardReport();
      case 'voucher':
        return this.getVoucherReport();
      case 'membership':
        return this.getMembershipReport();
      case 'top-customers':
        return this.getTopCustomers();
      default:
        return this.getWalletReport();
    }
  }

  private async getWalletReport() {
    const [totalWallets, balanceAgg, topupAgg, spendingAgg] =
      await this.prisma.$transaction([
        this.prisma.customerWallet.count({ where: { deletedAt: null } }),
        this.prisma.customerWallet.aggregate({
          where: { deletedAt: null },
          _sum: { currentBalance: true },
        }),
        this.prisma.walletTransaction.aggregate({
          where: { deletedAt: null, type: 'top_up' },
          _sum: { amount: true },
        }),
        this.prisma.walletTransaction.aggregate({
          where: { deletedAt: null, type: 'deduction' },
          _sum: { amount: true },
        }),
      ]);

    return {
      summary: {
        totalWallets,
        totalBalance: Number(balanceAgg._sum.currentBalance ?? 0),
        totalTopup: Number(topupAgg._sum.amount ?? 0),
        totalSpending: Number(spendingAgg._sum.amount ?? 0),
      },
    };
  }

  private async getRewardReport() {
    const [earned, redeemed, expired] = await this.prisma.$transaction([
      this.prisma.rewardPoint.aggregate({
        where: { deletedAt: null, type: 'earn' },
        _sum: { point: true },
      }),
      this.prisma.rewardPoint.aggregate({
        where: { deletedAt: null, type: 'redeem' },
        _sum: { point: true },
      }),
      this.prisma.rewardPoint.aggregate({
        where: { deletedAt: null, type: 'expired' },
        _sum: { point: true },
      }),
    ]);

    return {
      summary: {
        totalEarned: earned._sum.point ?? 0,
        totalRedeemed: Math.abs(redeemed._sum.point ?? 0),
        totalExpired: Math.abs(expired._sum.point ?? 0),
      },
    };
  }

  private async getVoucherReport() {
    const vouchers = await this.prisma.loyaltyVoucher.findMany({
      where: { deletedAt: null },
      orderBy: { usageCount: 'desc' },
    });

    return {
      summary: {
        totalVouchers: vouchers.length,
        activeVouchers: vouchers.filter((v) => v.status === 'ACTIVE').length,
        totalUsage: vouchers.reduce((sum, v) => sum + v.usageCount, 0),
      },
      items: vouchers.map((v) => ({
        code: v.code,
        name: v.name,
        usageCount: v.usageCount,
        usageLimit: v.usageLimit,
        status: v.status,
      })),
    };
  }

  private async getMembershipReport() {
    const customers = await this.prisma.customer.findMany({
      where: { deletedAt: null, isActive: true },
      select: { id: true, fullName: true, customerCode: true },
      take: 500,
    });

    const items = [];
    for (const customer of customers) {
      const membership = await this.membershipService.getMembership(customer.id);
      items.push({
        customerId: customer.id,
        customerName: customer.fullName,
        customerCode: customer.customerCode,
        level: membership.currentLevel.code,
        lifetimePoints: membership.lifetimePoints,
        currentPoints: membership.currentPoints,
      });
    }

    const summary = items.reduce<Record<string, number>>((acc, item) => {
      acc[item.level] = (acc[item.level] ?? 0) + 1;
      return acc;
    }, {});

    return { summary, items };
  }

  private async getTopCustomers() {
    const customers = await this.prisma.customer.findMany({
      where: { deletedAt: null },
      select: {
        id: true,
        fullName: true,
        customerCode: true,
        wallet: { select: { currentBalance: true } },
      },
      take: 200,
    });

    const items = await Promise.all(
      customers.map(async (customer) => {
        const paid = await this.prisma.payment.aggregate({
          where: {
            deletedAt: null,
            paymentStatus: 'PAID',
            order: {
              customerId: customer.id,
              deletedAt: null,
              orderStatus: 'COMPLETED',
            },
          },
          _sum: { amount: true },
        });

        return {
          customerId: customer.id,
          customerName: customer.fullName,
          customerCode: customer.customerCode,
          walletBalance: Number(customer.wallet?.currentBalance ?? 0),
          lifetimeSpending: Number(paid._sum.amount ?? 0),
        };
      }),
    );

    const ranked = items
      .sort((a, b) => b.lifetimeSpending - a.lifetimeSpending)
      .slice(0, 20);

    return { items: ranked };
  }
}
