export type MembershipLevelCode = "REGULAR" | "SILVER" | "GOLD" | "PLATINUM";

export interface MembershipLevel {
  code: MembershipLevelCode;
  name: string;
  minPoints: number;
  benefits: string[];
}

export interface LoyaltySettings {
  pointPerRupiah: number;
  rupiahPerPoint: number;
  pointExpirationDays: number;
  membershipLevels: MembershipLevel[];
  cashback: {
    enabled: boolean;
    type: "PERCENTAGE" | "FIXED";
    value: number;
    maxAmount: number;
    expirationDays: number;
  };
  wallet: {
    minTopup: number;
    allowManualDebit: boolean;
  };
}

export interface WalletDashboard {
  walletCount: number;
  currentBalance: number;
  totalTopup: number;
  totalSpending: number;
  totalRefund: number;
}

export interface WalletSummary {
  walletId: string;
  customerId: string;
  balance: number;
  currency: string;
  isActive: boolean;
  totalTopup: number;
  totalCashback: number;
  totalSpending: number;
  updatedAt: string;
}

export interface WalletTransaction {
  id: string;
  customerId: string;
  walletId: string;
  referenceNumber: string | null;
  type: string;
  amount: number;
  balanceAfter: number | null;
  notes: string | null;
  createdByEmployee: {
    id: string;
    fullName: string;
    employeeCode: string;
  } | null;
  createdAt: string;
}

export interface RewardSummary {
  currentPoint: number;
  earned: number;
  used: number;
  expired: number;
  lifetimePoint: number;
}

export interface RewardHistoryItem {
  id: string;
  customerId: string;
  activity: string;
  point: number;
  balance: number | null;
  reference: string | null;
  referenceType: string | null;
  description: string | null;
  employee: { id: string; fullName: string; employeeCode: string } | null;
  createdAt: string;
}

export interface MembershipSummary {
  currentLevel: MembershipLevel;
  nextLevel: MembershipLevel | null;
  lifetimePoints: number;
  currentPoints: number;
  progressPercent: number;
  pointsToNext: number;
}

export interface LoyaltyVoucher {
  id: string;
  code: string;
  name: string;
  discountType: "PERCENTAGE" | "FIXED";
  discountValue: number;
  cashbackType: "PERCENTAGE" | "FIXED" | null;
  cashbackValue: number | null;
  cashbackMax: number | null;
  cashbackExpirationDays: number | null;
  startDate: string;
  endDate: string;
  usageLimit: number;
  usageCount: number;
  minimumTransaction: number;
  status: "ACTIVE" | "INACTIVE" | "EXPIRED";
}

export interface CustomerLoyalty {
  walletBalance: number;
  totalTopup: number;
  totalSpending: number;
  totalRefund: number;
  rewardPoint: RewardSummary;
  membership: MembershipSummary;
  voucherCount: number;
  lastTopup: { amount: number; date: string } | null;
  lifetimeSpending: number;
}

export interface WalletHistoryParams {
  page?: number;
  limit?: number;
  customerId?: string;
  type?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface VoucherListParams {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}
