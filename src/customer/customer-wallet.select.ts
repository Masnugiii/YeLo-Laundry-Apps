import { Prisma } from '@prisma/client';

export const customerWalletSelect = {
  id: true,
  customerId: true,
  currentBalance: true,
  currency: true,
  isActive: true,
  balanceUpdatedAt: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.CustomerWalletSelect;

export const customerWalletTransactionSelect = {
  id: true,
  customerId: true,
  walletId: true,
  referenceNumber: true,
  amount: true,
  balanceAfter: true,
  type: true,
  description: true,
  createdByEmployeeId: true,
  createdAt: true,
  createdByEmployee: {
    select: {
      id: true,
      fullName: true,
      employeeCode: true,
    },
  },
} satisfies Prisma.WalletTransactionSelect;

export type CustomerWalletRecord = Prisma.CustomerWalletGetPayload<{
  select: typeof customerWalletSelect;
}>;

export type CustomerWalletTransactionRecord = Prisma.WalletTransactionGetPayload<{
  select: typeof customerWalletTransactionSelect;
}>;
