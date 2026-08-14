import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import {
  CashflowType,
  ReferenceType,
  WalletTransactionType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import {
  toCustomerWalletSummary,
  toCustomerWalletTransactionItem,
} from '../customer/customer-wallet.mapper';
import { LoyaltySettingsService } from './loyalty-settings.service';
import { RewardService } from './reward.service';

@Injectable()
export class WalletLoyaltyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletRepository: CustomerWalletRepository,
    private readonly settingsService: LoyaltySettingsService,
    private readonly rewardService: RewardService,
  ) {}

  async getDashboard() {
    const [walletCount, totalBalance, topupAgg, spendingAgg, refundAgg] =
      await this.prisma.$transaction([
        this.prisma.customerWallet.count({
          where: { deletedAt: null, isActive: true },
        }),
        this.prisma.customerWallet.aggregate({
          where: { deletedAt: null, isActive: true },
          _sum: { currentBalance: true },
        }),
        this.prisma.walletTransaction.aggregate({
          where: { deletedAt: null, type: WalletTransactionType.top_up },
          _sum: { amount: true },
        }),
        this.prisma.walletTransaction.aggregate({
          where: { deletedAt: null, type: WalletTransactionType.deduction },
          _sum: { amount: true },
        }),
        this.prisma.walletTransaction.aggregate({
          where: { deletedAt: null, type: WalletTransactionType.refund },
          _sum: { amount: true },
        }),
      ]);

    return {
      walletCount,
      currentBalance: Number(totalBalance._sum.currentBalance ?? 0),
      totalTopup: Number(topupAgg._sum.amount ?? 0),
      totalSpending: Number(spendingAgg._sum.amount ?? 0),
      totalRefund: Number(refundAgg._sum.amount ?? 0),
    };
  }

  async topupWithCashflow(
    customerId: string,
    amount: number,
    notes: string | undefined,
    employeeId: string,
  ) {
    const settings = await this.settingsService.getSettings();
    if (amount < settings.wallet.minTopup) {
      throw new BadRequestException(
        `Minimum top-up is ${settings.wallet.minTopup}`,
      );
    }

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();
    const result = await this.walletRepository.applyMutation({
      customerId,
      amount,
      type: WalletTransactionType.top_up,
      description: notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit: true,
      referenceType: 'WALLET_TOPUP',
    });

    if ('insufficientBalance' in result) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    await this.prisma.cashflow.create({
      data: {
        type: CashflowType.INCOME,
        referenceType: ReferenceType.WALLET_TOPUP,
        referenceId: result.transaction.id,
        amount,
        transactionDate: new Date(),
        description: `Wallet top-up ${referenceNumber}`,
        createdByEmployeeId: employeeId,
      },
    });

    await this.rewardService.earnFromDeposit(
      customerId,
      amount,
      'WALLET_TOPUP',
      result.transaction.id,
      employeeId,
    );

    return {
      transaction: toCustomerWalletTransactionItem(result.transaction),
      wallet: toCustomerWalletSummary(result.wallet, result.aggregates),
    };
  }

  async adjust(
    customerId: string,
    amount: number,
    direction: 'INCREASE' | 'DECREASE',
    notes: string | undefined,
    employeeId: string,
  ) {
    const isCredit = direction === 'INCREASE';
    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();
    const result = await this.walletRepository.applyMutation({
      customerId,
      amount,
      type: isCredit
        ? WalletTransactionType.manual_credit
        : WalletTransactionType.manual_debit,
      description: notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit,
      referenceType: 'WALLET_ADJUSTMENT',
    });

    if ('insufficientBalance' in result) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    return {
      transaction: toCustomerWalletTransactionItem(result.transaction),
      wallet: toCustomerWalletSummary(result.wallet, result.aggregates),
    };
  }

  async refund(
    customerId: string,
    amount: number,
    notes: string | undefined,
    employeeId: string,
    referenceId?: string,
  ) {
    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();
    const result = await this.walletRepository.applyMutation({
      customerId,
      amount,
      type: WalletTransactionType.refund,
      description: notes?.trim(),
      employeeId,
      referenceNumber,
      isCredit: true,
      referenceType: 'REFUND',
      referenceId,
    });

    if ('insufficientBalance' in result) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    return {
      transaction: toCustomerWalletTransactionItem(result.transaction),
      wallet: toCustomerWalletSummary(result.wallet, result.aggregates),
    };
  }

  async reverseTransaction(transactionId: string, employeeId: string) {
    const original = await this.prisma.walletTransaction.findFirst({
      where: { id: transactionId, deletedAt: null },
    });
    if (!original) throw new NotFoundException('Transaction not found');
    if (original.reversedTransactionId) {
      throw new BadRequestException('Transaction already reversed');
    }

    const debitTypes: WalletTransactionType[] = [
      WalletTransactionType.deduction,
      WalletTransactionType.manual_debit,
    ];
    const isCredit = debitTypes.includes(original.type);

    const referenceNumber =
      await this.walletRepository.generateNextReferenceNumber();
    const result = await this.walletRepository.applyMutation({
      customerId: original.customerId,
      amount: Number(original.amount),
      type: WalletTransactionType.adjustment,
      description: `Reversal of ${original.referenceNumber ?? original.id}`,
      employeeId,
      referenceNumber,
      isCredit,
      referenceType: 'WALLET_REVERSAL',
      referenceId: original.id,
    });

    if ('insufficientBalance' in result) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    await this.prisma.walletTransaction.update({
      where: { id: original.id },
      data: { reversedTransactionId: result.transaction.id },
    });

    return {
      transaction: toCustomerWalletTransactionItem(result.transaction),
      wallet: toCustomerWalletSummary(result.wallet, result.aggregates),
    };
  }
}
