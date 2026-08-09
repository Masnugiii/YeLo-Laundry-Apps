import { WalletTransactionType } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';
import { WalletTransactionTypeFilter } from './dto/wallet-transaction-query.dto';
import {
  CustomerWalletRecord,
  CustomerWalletTransactionRecord,
} from './customer-wallet.select';

export const CASHBACK_DESCRIPTION_PREFIX = '[CASHBACK]';

export interface CustomerWalletSummary {
  walletId: string;
  customerId: string;
  balance: number;
  currency: string;
  isActive: boolean;
  totalTopup: number;
  totalCashback: number;
  totalSpending: number;
  updatedAt: Date;
}

export interface CustomerWalletTransactionItem {
  id: string;
  customerId: string;
  walletId: string;
  referenceNumber: string | null;
  type: WalletTransactionTypeFilter;
  amount: number;
  balanceAfter: number | null;
  notes: string | null;
  createdByEmployeeId: string | null;
  createdByEmployee: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  createdAt: Date;
}

export interface WalletMutationResult {
  transaction: CustomerWalletTransactionItem;
  wallet: CustomerWalletSummary;
}

export interface PaginatedWalletTransactions {
  items: CustomerWalletTransactionItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

function decimalToNumber(value: Decimal | number): number {
  return Number(value);
}

export function mapPrismaTypeToApiType(
  type: WalletTransactionType,
  description: string | null,
): WalletTransactionTypeFilter {
  if (
    type === WalletTransactionType.adjustment &&
    description?.startsWith(CASHBACK_DESCRIPTION_PREFIX)
  ) {
    return WalletTransactionTypeFilter.CASHBACK;
  }

  switch (type) {
    case WalletTransactionType.top_up:
      return WalletTransactionTypeFilter.TOPUP;
    case WalletTransactionType.deduction:
      return WalletTransactionTypeFilter.PAYMENT;
    case WalletTransactionType.refund:
      return WalletTransactionTypeFilter.REFUND;
    case WalletTransactionType.adjustment:
      return WalletTransactionTypeFilter.ADJUSTMENT;
    case WalletTransactionType.promotion:
      return description?.startsWith(CASHBACK_DESCRIPTION_PREFIX)
        ? WalletTransactionTypeFilter.CASHBACK
        : WalletTransactionTypeFilter.PROMOTION;
    case WalletTransactionType.manual_credit:
      return WalletTransactionTypeFilter.MANUAL_CREDIT;
    case WalletTransactionType.manual_debit:
      return WalletTransactionTypeFilter.MANUAL_DEBIT;
    default:
      return WalletTransactionTypeFilter.ADJUSTMENT;
  }
}

export function toCustomerWalletSummary(
  wallet: CustomerWalletRecord,
  aggregates: {
    totalTopup: number;
    totalCashback: number;
    totalSpending: number;
  },
): CustomerWalletSummary {
  return {
    walletId: wallet.id,
    customerId: wallet.customerId,
    balance: decimalToNumber(wallet.currentBalance),
    currency: wallet.currency,
    isActive: wallet.isActive,
    totalTopup: aggregates.totalTopup,
    totalCashback: aggregates.totalCashback,
    totalSpending: aggregates.totalSpending,
    updatedAt: wallet.balanceUpdatedAt,
  };
}

export function toCustomerWalletTransactionItem(
  transaction: CustomerWalletTransactionRecord,
): CustomerWalletTransactionItem {
  return {
    id: transaction.id,
    customerId: transaction.customerId,
    walletId: transaction.walletId,
    referenceNumber: transaction.referenceNumber,
    type: mapPrismaTypeToApiType(transaction.type, transaction.description),
    amount: decimalToNumber(transaction.amount),
    balanceAfter:
      transaction.balanceAfter === null || transaction.balanceAfter === undefined
        ? null
        : decimalToNumber(transaction.balanceAfter),
    notes: transaction.description,
    createdByEmployeeId: transaction.createdByEmployeeId,
    createdByEmployee: transaction.createdByEmployee,
    createdAt: transaction.createdAt,
  };
}
