import { Injectable } from '@nestjs/common';
import { WalletTransactionType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { CASHBACK_DESCRIPTION_PREFIX } from '../customer/customer-wallet.mapper';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { RewardService } from './reward.service';

@Injectable()
export class LoyaltyProcessorService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settingsService: LoyaltySettingsService,
    private readonly rewardService: RewardService,
    private readonly walletRepository: CustomerWalletRepository,
  ) {}

  async processOrderCompleted(orderId: string, employeeId?: string) {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, deletedAt: null },
      select: {
        id: true,
        customerId: true,
        orderStatus: true,
        items: {
          where: { deletedAt: null },
          select: { subtotal: true },
        },
      },
    });

    if (!order || order.orderStatus !== 'COMPLETED') {
      return null;
    }

    const paidTotal = await this.prisma.payment.aggregate({
      where: {
        orderId,
        deletedAt: null,
        paymentStatus: 'PAID',
      },
      _sum: { amount: true },
    });
    const orderTotal = order.items.reduce(
      (sum, item) => sum + Number(item.subtotal),
      0,
    );
    const amount = Number(paidTotal._sum.amount ?? orderTotal);

    await this.rewardService.earnFromPayment(
      order.customerId,
      order.id,
      amount,
      employeeId,
    );

    await this.applyCashback(order.customerId, order.id, amount, employeeId);

    return { orderId: order.id, customerId: order.customerId, amount };
  }

  private async applyCashback(
    customerId: string,
    orderId: string,
    amount: number,
    employeeId?: string,
  ) {
    const settings = await this.settingsService.getSettings();
    if (!settings.cashback.enabled || amount <= 0) return null;

    const existing = await this.prisma.walletTransaction.findFirst({
      where: {
        customerId,
        referenceId: orderId,
        referenceType: 'ORDER',
        deletedAt: null,
        description: { startsWith: CASHBACK_DESCRIPTION_PREFIX },
      },
    });
    if (existing) return existing;

    let cashbackAmount =
      settings.cashback.type === 'PERCENTAGE'
        ? (amount * settings.cashback.value) / 100
        : settings.cashback.value;
    cashbackAmount = Math.min(cashbackAmount, settings.cashback.maxAmount);
    if (cashbackAmount <= 0) return null;

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();

    return this.walletRepository.applyMutation({
      customerId,
      amount: cashbackAmount,
      type: WalletTransactionType.promotion,
      description: `${CASHBACK_DESCRIPTION_PREFIX} Order ${orderId}`,
      employeeId: employeeId ?? '',
      referenceNumber,
      isCredit: true,
      referenceType: 'ORDER',
      referenceId: orderId,
    });
  }
}
