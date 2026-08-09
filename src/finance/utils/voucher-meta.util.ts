export type VoucherDiscountType = 'PERCENTAGE' | 'FIXED';

export interface VoucherRecord {
  code: string;
  type: VoucherDiscountType;
  value: number;
  expiresAt: string;
  maxUsage: number;
  usedCount: number;
  isActive: boolean;
  createdAt: string;
  createdByEmployeeId: string;
}

export const VOUCHER_SETTING_PREFIX = 'finance.voucher.';

export function buildVoucherSettingKey(code: string): string {
  return `${VOUCHER_SETTING_PREFIX}${code.trim().toUpperCase()}`;
}

export function parseVoucherRecord(value: string): VoucherRecord | null {
  try {
    return JSON.parse(value) as VoucherRecord;
  } catch {
    return null;
  }
}

export function isVoucherExpired(voucher: VoucherRecord, now = new Date()): boolean {
  return new Date(voucher.expiresAt) < now;
}

export function getVoucherRemainingUsage(voucher: VoucherRecord): number {
  return Math.max(voucher.maxUsage - voucher.usedCount, 0);
}
