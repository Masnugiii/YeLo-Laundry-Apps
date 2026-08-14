import { RewardEntitlementStatus } from '@prisma/client';

export const CKS_SERVICE_TYPE = 'CKS';

export interface EntitlementKgSplit {
  orderKg: number;
  freeKg: number;
  billableKg: number;
  remainingKgAfter: number;
}

export function splitEntitlementKg(
  remainingKg: number,
  orderKg: number,
): EntitlementKgSplit {
  const safeRemaining = Math.max(0, Number(remainingKg) || 0);
  const safeOrderKg = Math.max(0, Number(orderKg) || 0);
  const freeKg = Math.min(safeRemaining, safeOrderKg);
  const billableKg = Number((safeOrderKg - freeKg).toFixed(3));
  const remainingKgAfter = Number((safeRemaining - freeKg).toFixed(3));

  return {
    orderKg: Number(safeOrderKg.toFixed(3)),
    freeKg: Number(freeKg.toFixed(3)),
    billableKg,
    remainingKgAfter,
  };
}

export function resolveEntitlementStatus(input: {
  remainingKg: number;
  entitlementKg: number;
  expiresAt: Date | null | undefined;
  currentStatus?: RewardEntitlementStatus | null;
  now?: Date;
}): RewardEntitlementStatus {
  if (input.currentStatus === RewardEntitlementStatus.CANCELLED) {
    return RewardEntitlementStatus.CANCELLED;
  }

  const now = input.now ?? new Date();
  if (input.expiresAt && input.expiresAt.getTime() <= now.getTime()) {
    return RewardEntitlementStatus.EXPIRED;
  }

  if (input.remainingKg <= 0) {
    return RewardEntitlementStatus.USED;
  }

  if (input.remainingKg < input.entitlementKg) {
    return RewardEntitlementStatus.PARTIALLY_USED;
  }

  return RewardEntitlementStatus.AVAILABLE;
}

export function isUsableEntitlementStatus(
  status: RewardEntitlementStatus,
): boolean {
  return (
    status === RewardEntitlementStatus.AVAILABLE ||
    status === RewardEntitlementStatus.PARTIALLY_USED
  );
}

export function addDays(from: Date, days: number): Date {
  const result = new Date(from.getTime());
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}
