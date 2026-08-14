import {
  DEFAULT_LOYALTY_SETTINGS,
  DepositPointRule,
  LaundryPointRule,
  LoyaltySettings,
} from './loyalty.types';

/** Default laundry earn unit (Rp per 1 point). */
export const LAUNDRY_RUPIAH_PER_POINT = 50_000;
/** Default deposit unit amount. */
export const DEPOSIT_UNIT_AMOUNT = 250_000;
/** Default points per deposit unit. */
export const DEPOSIT_POINTS_PER_UNIT = 6;

export function resolveLaundryPointRule(
  settings?: Pick<LoyaltySettings, 'laundryPoint' | 'rupiahPerPoint' | 'pointPerRupiah'>,
): LaundryPointRule {
  if (settings?.laundryPoint) {
    return settings.laundryPoint;
  }

  return {
    enabled: true,
    minimumTransaction:
      settings?.rupiahPerPoint ?? DEFAULT_LOYALTY_SETTINGS.laundryPoint.minimumTransaction,
    pointsPerUnit:
      settings?.pointPerRupiah ?? DEFAULT_LOYALTY_SETTINGS.laundryPoint.pointsPerUnit,
  };
}

export function resolveDepositPointRule(
  settings?: Pick<LoyaltySettings, 'depositPoint'>,
): DepositPointRule {
  return settings?.depositPoint ?? DEFAULT_LOYALTY_SETTINGS.depositPoint;
}

/** floor(amount / minimumTransaction) * pointsPerUnit */
export function calculateLaundryPaymentPoints(
  amount: number,
  rule?: LaundryPointRule,
): number {
  const resolved = rule ?? DEFAULT_LOYALTY_SETTINGS.laundryPoint;

  if (!resolved.enabled || !Number.isFinite(amount) || amount <= 0) {
    return 0;
  }

  if (resolved.minimumTransaction <= 0 || resolved.pointsPerUnit <= 0) {
    return 0;
  }

  return (
    Math.floor(amount / resolved.minimumTransaction) * resolved.pointsPerUnit
  );
}

/** floor(depositAmount / minimumDeposit) * pointsPerMultiplier */
export function calculateDepositPoints(
  depositAmount: number,
  rule?: DepositPointRule,
): number {
  const resolved = rule ?? DEFAULT_LOYALTY_SETTINGS.depositPoint;

  if (!resolved.enabled || !Number.isFinite(depositAmount) || depositAmount <= 0) {
    return 0;
  }

  if (resolved.minimumDeposit <= 0 || resolved.pointsPerMultiplier <= 0) {
    return 0;
  }

  return (
    Math.floor(depositAmount / resolved.minimumDeposit) *
    resolved.pointsPerMultiplier
  );
}

export function buildPointExpirationDate(
  pointExpirationDays: number,
  from: Date = new Date(),
): Date {
  const expiredAt = new Date(from);
  const days =
    Number.isFinite(pointExpirationDays) && pointExpirationDays > 0
      ? Math.floor(pointExpirationDays)
      : 0;
  expiredAt.setDate(expiredAt.getDate() + days);
  return expiredAt;
}
