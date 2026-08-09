export const NUMBERING_TYPES = ['ORD', 'INV', 'EXP', 'PAY', 'CST', 'EMP'] as const;

export type NumberingType = (typeof NUMBERING_TYPES)[number];

export function isNumberingType(value: string): value is NumberingType {
  return (NUMBERING_TYPES as readonly string[]).includes(value);
}

export function formatOrderDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}${month}${day}`;
}

export function formatDailyNumber(
  prefix: string,
  counter: number,
  padding: number,
  date = new Date(),
): string {
  return `${prefix}-${formatOrderDate(date)}-${String(counter).padStart(padding, '0')}`;
}

export function formatSequentialNumber(
  prefix: string,
  counter: number,
  padding: number,
): string {
  return `${prefix}-${String(counter).padStart(padding, '0')}`;
}

export interface NumberingSequenceConfig {
  id: string;
  type: string;
  prefix: string;
  currentCounter: number;
  padding: number;
  dailyReset: boolean;
  lastResetDate: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}
