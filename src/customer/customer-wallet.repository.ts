import { Injectable } from '@nestjs/common';
import { Prisma, WalletTransactionType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  WalletTransactionQueryDto,
  WalletTransactionTypeFilter,
} from './dto/wallet-transaction-query.dto';
import { CASHBACK_DESCRIPTION_PREFIX } from './customer-wallet.mapper';
import {
  customerWalletSelect,
  customerWalletTransactionSelect,
} from './customer-wallet.select';
import {
  buildWalletReferencePrefix,
  formatWalletReferenceNumber,
  parseWalletReferenceSequence,
} from './utils/wallet-reference.util';

interface WalletMutationParams {
  customerId: string;
  amount: number;
  type: WalletTransactionType;
  description?: string;
  employeeId?: string | null;
  referenceNumber: string;
  isCredit: boolean;
  referenceType?: string;
  referenceId?: string;
  tx?: Prisma.TransactionClient;
}

@Injectable()
export class CustomerWalletRepository {
  constructor(private readonly prisma: PrismaService) {}

  findWalletByCustomerId(customerId: string) {
    return this.prisma.customerWallet.findFirst({
      where: { customerId, deletedAt: null },
      select: customerWalletSelect,
    });
  }

  async ensureWalletForCustomer(customerId: string) {
    const existing = await this.findWalletByCustomerId(customerId);
    if (existing) {
      return existing;
    }

    return this.prisma.customerWallet.upsert({
      where: { customerId },
      create: {
        customerId,
        currentBalance: 0,
      },
      update: {
        deletedAt: null,
        isActive: true,
      },
      select: customerWalletSelect,
    });
  }

  findAllTransactions(query: {
    page: number;
    limit: number;
    type?: WalletTransactionTypeFilter;
    dateFrom?: Date;
    dateTo?: Date;
  }) {
    const skip = (query.page - 1) * query.limit;
    const where: Prisma.WalletTransactionWhereInput = {
      deletedAt: null,
      ...(query.dateFrom || query.dateTo
        ? {
            createdAt: {
              ...(query.dateFrom ? { gte: query.dateFrom } : {}),
              ...(query.dateTo ? { lte: query.dateTo } : {}),
            },
          }
        : {}),
      ...(query.type ? this.mapApiTypeToPrismaFilter(query.type) : {}),
    };

    return this.prisma.$transaction([
      this.prisma.walletTransaction.findMany({
        where,
        skip,
        take: query.limit,
        orderBy: { createdAt: 'desc' },
        select: customerWalletTransactionSelect,
      }),
      this.prisma.walletTransaction.count({ where }),
    ]);
  }

  findTransactions(customerId: string, query: WalletTransactionQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildTransactionWhere(customerId, query);

    return this.prisma.$transaction([
      this.prisma.walletTransaction.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: customerWalletTransactionSelect,
      }),
      this.prisma.walletTransaction.count({ where }),
    ]);
  }

  async getWalletAggregates(customerId: string, walletId: string) {
    const [topup, spending, cashback] = await this.prisma.$transaction([
      this.prisma.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.top_up,
        },
        _sum: { amount: true },
      }),
      this.prisma.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.deduction,
        },
        _sum: { amount: true },
      }),
      this.prisma.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.adjustment,
          description: { startsWith: CASHBACK_DESCRIPTION_PREFIX },
        },
        _sum: { amount: true },
      }),
    ]);

    return {
      totalTopup: Number(topup._sum.amount ?? 0),
      totalSpending: Number(spending._sum.amount ?? 0),
      totalCashback: Number(cashback._sum.amount ?? 0),
    };
  }

  async generateNextReferenceNumber(date = new Date()): Promise<string> {
    const prefix = buildWalletReferencePrefix(date);

    const latest = await this.prisma.walletTransaction.findFirst({
      where: {
        referenceNumber: { startsWith: prefix },
      },
      orderBy: { referenceNumber: 'desc' },
      select: { referenceNumber: true },
    });

    const latestSequence = latest?.referenceNumber
      ? parseWalletReferenceSequence(latest.referenceNumber, prefix)
      : null;

    return formatWalletReferenceNumber((latestSequence ?? 0) + 1, date);
  }

  applyMutation(params: WalletMutationParams) {
    const run = async (tx: Prisma.TransactionClient) =>
      this.applyMutationInTx(tx, params);

    if (params.tx) {
      return run(params.tx);
    }

    return this.prisma.$transaction(run);
  }

  private async applyMutationInTx(
    tx: Prisma.TransactionClient,
    params: WalletMutationParams,
  ) {
      let wallet = await tx.customerWallet.findFirst({
        where: { customerId: params.customerId, deletedAt: null },
        select: customerWalletSelect,
      });

      if (!wallet) {
        wallet = await tx.customerWallet.upsert({
          where: { customerId: params.customerId },
          create: {
            customerId: params.customerId,
            currentBalance: 0,
          },
          update: {
            deletedAt: null,
            isActive: true,
          },
          select: customerWalletSelect,
        });
      }

      const currentBalance = Number(wallet.currentBalance);
      const nextBalance = params.isCredit
        ? currentBalance + params.amount
        : currentBalance - params.amount;

      if (nextBalance < 0) {
        return {
          insufficientBalance: true as const,
          wallet,
        };
      }

      const updatedWallet = await tx.customerWallet.update({
        where: { id: wallet.id },
        data: {
          currentBalance: nextBalance,
          balanceUpdatedAt: new Date(),
        },
        select: customerWalletSelect,
      });

      const transaction = await tx.walletTransaction.create({
        data: {
          customerId: params.customerId,
          walletId: wallet.id,
          amount: params.amount,
          type: params.type,
          referenceNumber: params.referenceNumber,
          description: params.description,
          createdByEmployeeId: params.employeeId ?? null,
          balanceAfter: nextBalance,
          referenceType: params.referenceType,
          referenceId: params.referenceId,
        },
        select: customerWalletTransactionSelect,
      });

      const aggregates = await this.getWalletAggregatesInTx(
        tx,
        params.customerId,
        wallet.id,
      );

      return {
        wallet: updatedWallet,
        transaction,
        aggregates,
      };
  }

  private async getWalletAggregatesInTx(
    tx: Prisma.TransactionClient,
    customerId: string,
    walletId: string,
  ) {
    const [topup, spending, cashback] = await Promise.all([
      tx.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.top_up,
        },
        _sum: { amount: true },
      }),
      tx.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.deduction,
        },
        _sum: { amount: true },
      }),
      tx.walletTransaction.aggregate({
        where: {
          customerId,
          walletId,
          deletedAt: null,
          type: WalletTransactionType.adjustment,
          description: { startsWith: CASHBACK_DESCRIPTION_PREFIX },
        },
        _sum: { amount: true },
      }),
    ]);

    return {
      totalTopup: Number(topup._sum.amount ?? 0),
      totalSpending: Number(spending._sum.amount ?? 0),
      totalCashback: Number(cashback._sum.amount ?? 0),
    };
  }

  private buildTransactionWhere(
    customerId: string,
    query: WalletTransactionQueryDto,
  ): Prisma.WalletTransactionWhereInput {
    const where: Prisma.WalletTransactionWhereInput = {
      customerId,
      deletedAt: null,
    };

    if (query.type) {
      Object.assign(where, this.mapApiTypeToPrismaFilter(query.type));
    }

    if (query.dateFrom || query.dateTo) {
      where.createdAt = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    return where;
  }

  private mapApiTypeToPrismaFilter(
    type: WalletTransactionTypeFilter,
  ): Prisma.WalletTransactionWhereInput {
    switch (type) {
      case WalletTransactionTypeFilter.TOPUP:
        return { type: WalletTransactionType.top_up };
      case WalletTransactionTypeFilter.PAYMENT:
        return { type: WalletTransactionType.deduction };
      case WalletTransactionTypeFilter.REFUND:
        return { type: WalletTransactionType.refund };
      case WalletTransactionTypeFilter.ADJUSTMENT:
        return {
          type: WalletTransactionType.adjustment,
          NOT: {
            description: { startsWith: CASHBACK_DESCRIPTION_PREFIX },
          },
        };
      case WalletTransactionTypeFilter.CASHBACK:
        return {
          type: WalletTransactionType.adjustment,
          description: { startsWith: CASHBACK_DESCRIPTION_PREFIX },
        };
      case WalletTransactionTypeFilter.PROMOTION:
        return { type: WalletTransactionType.promotion };
      case WalletTransactionTypeFilter.MANUAL_CREDIT:
        return { type: WalletTransactionType.manual_credit };
      case WalletTransactionTypeFilter.MANUAL_DEBIT:
        return { type: WalletTransactionType.manual_debit };
      default:
        return {};
    }
  }
}
