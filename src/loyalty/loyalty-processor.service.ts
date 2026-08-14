import { Injectable } from '@nestjs/common';
import { PaymentStatus, WalletTransactionType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { CASHBACK_DESCRIPTION_PREFIX } from '../customer/customer-wallet.mapper';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { RewardService } from './reward.service';

const WALLET_PAYMENT_METHOD_CODE = 'YELO_WALLET';

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
        paymentStatus: true,
        items: {
          where: { deletedAt: null },
          select: { subtotal: true },
        },
      },
    });

    if (!order || order.orderStatus !== 'COMPLETED') {
      return null;
    }

    // No installment / partial loyalty earning: require fully paid order.
    if (order.paymentStatus !== 'PAID') {
      return null;
    }

    const payments = await this.prisma.payment.findMany({
      where: {
        orderId,
        deletedAt: null,
        paymentStatus: PaymentStatus.PAID,
      },
      select: {
        amount: true,
        paymentMethod: { select: { code: true } },
      },
    });

    const paidTotal = payments.reduce(
      (sum, payment) => sum + Number(payment.amount),
      0,
    );
    const walletPaidTotal = payments
      .filter((payment) => payment.paymentMethod.code === WALLET_PAYMENT_METHOD_CODE)
      .reduce((sum, payment) => sum + Number(payment.amount), 0);

    // Wallet/deposit funds already earn at top-up — exclude from laundry points.
    const eligibleLaundryAmount = Math.max(paidTotal - walletPaidTotal, 0);

    await this.rewardService.earnFromPayment(
      order.customerId,
      order.id,
      eligibleLaundryAmount,
      employeeId,
    );

    await this.applyCashback(order.customerId, order.id, paidTotal, employeeId);

    return {
      orderId: order.id,
      customerId: order.customerId,
      amount: paidTotal,
      eligibleLaundryAmount,
      walletPaidTotal,
    };
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
