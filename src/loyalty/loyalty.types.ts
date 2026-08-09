export type MembershipLevelCode = 'REGULAR' | 'SILVER' | 'GOLD' | 'PLATINUM';

export interface MembershipLevel {
  code: MembershipLevelCode;
  name: string;
  minPoints: number;
  benefits: string[];
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

export interface LoyaltySettings {
  pointPerRupiah: number;
  rupiahPerPoint: number;
  pointExpirationDays: number;
  membershipLevels: MembershipLevel[];
  cashback: CashbackRule;
  wallet: WalletRules;
}

export const LOYALTY_SETTINGS_KEY = 'loyalty.settings';

export const DEFAULT_LOYALTY_SETTINGS: LoyaltySettings = {
  pointPerRupiah: 1,
  rupiahPerPoint: 1000,
  pointExpirationDays: 365,
  membershipLevels: [
    { code: 'REGULAR', name: 'Regular', minPoints: 0, benefits: [] },
    {
      code: 'SILVER',
      name: 'Silver',
      minPoints: 500,
      benefits: ['Free Pickup'],
    },
    {
      code: 'GOLD',
      name: 'Gold',
      minPoints: 1500,
      benefits: ['Free Delivery'],
    },
    {
      code: 'PLATINUM',
      name: 'Platinum',
      minPoints: 3000,
      benefits: ['10% Discount', 'Priority Queue'],
    },
  ],
  cashback: {
    enabled: true,
    type: 'PERCENTAGE',
    value: 5,
    maxAmount: 50000,
    expirationDays: 30,
  },
  wallet: {
    minTopup: 10000,
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
  used: number;
  expired: number;
  lifetimePoint: number;
}
