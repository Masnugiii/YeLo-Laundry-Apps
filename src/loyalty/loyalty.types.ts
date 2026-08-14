export type MembershipLevelCode = 'REGULAR' | 'SILVER' | 'GOLD' | 'PLATINUM';

export interface MembershipLevel {
  code: MembershipLevelCode;
  name: string;
  minPoints: number;
  benefits: string[];
  active?: boolean;
}

export interface CashbackRule {
  enabled: boolean;
  type: 'PERCENTAGE' | 'FIXED';
  value: number;
  maxAmount: number;
  expirationDays: number;
}

export interface WalletRules {
  minTopup: number;
  allowManualDebit: boolean;
}

export interface LaundryPointRule {
  enabled: boolean;
  /** Rupiah per point unit — floor(amount / minimumTransaction) * pointsPerUnit */
  minimumTransaction: number;
  pointsPerUnit: number;
}

export interface DepositPointRule {
  enabled: boolean;
  /** Deposit unit amount — floor(deposit / minimumDeposit) * pointsPerMultiplier */
  minimumDeposit: number;
  pointsPerMultiplier: number;
}

export interface LoyaltySettings {
  /** @deprecated Use laundryPoint.pointsPerUnit — kept for backward compatibility */
  pointPerRupiah: number;
  /** @deprecated Use laundryPoint.minimumTransaction — kept for backward compatibility */
  rupiahPerPoint: number;
  pointExpirationDays: number;
  laundryPoint: LaundryPointRule;
  depositPoint: DepositPointRule;
  membershipLevels: MembershipLevel[];
  cashback: CashbackRule;
  wallet: WalletRules;
}

export const LOYALTY_SETTINGS_KEY = 'loyalty.settings';

export const DEFAULT_LOYALTY_SETTINGS: LoyaltySettings = {
  pointPerRupiah: 1,
  rupiahPerPoint: 50_000,
  pointExpirationDays: 365,
  laundryPoint: {
    enabled: true,
    minimumTransaction: 50_000,
    pointsPerUnit: 1,
  },
  depositPoint: {
    enabled: true,
    minimumDeposit: 250_000,
    pointsPerMultiplier: 6,
  },
  membershipLevels: [
    { code: 'REGULAR', name: 'Regular', minPoints: 0, benefits: [], active: true },
    {
      code: 'SILVER',
      name: 'Silver',
      minPoints: 500,
      benefits: ['Free Pickup'],
      active: true,
    },
    {
      code: 'GOLD',
      name: 'Gold',
      minPoints: 1500,
      benefits: ['Free Delivery'],
      active: true,
    },
    {
      code: 'PLATINUM',
      name: 'Platinum',
      minPoints: 3000,
      benefits: ['10% Discount', 'Priority Queue'],
      active: true,
    },
  ],
  cashback: {
    enabled: true,
    type: 'PERCENTAGE',
    value: 5,
    maxAmount: 50_000,
    expirationDays: 30,
  },
  wallet: {
    minTopup: 10_000,
    allowManualDebit: true,
  },
};

export interface MembershipSummary {
  currentLevel: MembershipLevel;
  nextLevel: MembershipLevel | null;
  lifetimePoints: number;
  currentPoints: number;
  progressPercent: number;
  pointsToNext: number;
}

export interface RewardSummary {
  currentPoint: number;
  earned: number;
  /** Points spent via redeem ledger entries. */
  redeemed: number;
  /** Backward-compatible alias: redeemed + clawback. */
  used: number;
  expired: number;
  clawback: number;
  lifetimePoint: number;
}
