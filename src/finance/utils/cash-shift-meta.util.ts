export type CashShiftStatus = 'OPEN' | 'CLOSED';

export interface CashShiftRecord {
  id: string;
  status: CashShiftStatus;
  openedAt: string;
  openedByEmployeeId: string;
  openingCash: number;
  closedAt?: string;
  closedByEmployeeId?: string;
  expectedCash?: number;
  actualCash?: number;
  difference?: number;
  totalCashIn: number;
  totalCashOut: number;
  notes?: string;
}

export interface CashTransactionRecord {
  id: string;
  shiftId: string;
  type: 'CASH_IN' | 'CASH_OUT';
  amount: number;
  description?: string;
  createdAt: string;
  createdByEmployeeId: string;
}

export interface DailyClosingRecord {
  closingDate: string;
  openingCash: number;
  income: number;
  expense: number;
  refund: number;
  closingCash: number;
  generatedAt: string;
  generatedByEmployeeId: string;
}

export const ACTIVE_SHIFT_KEY = 'finance.cash_shift.active';
export const SHIFT_HISTORY_PREFIX = 'finance.cash_shift.history.';
export const DAILY_CLOSING_PREFIX = 'finance.daily_closing.';
export const EXPENSE_AUTO_APPROVE_KEY = 'finance.expense.auto_approve_limit';

export function buildShiftHistoryKey(shiftId: string): string {
  return `${SHIFT_HISTORY_PREFIX}${shiftId}`;
}

export function buildDailyClosingKey(date: string): string {
  return `${DAILY_CLOSING_PREFIX}${date}`;
}

export function parseCashShiftRecord(value: string): CashShiftRecord | null {
  try {
    return JSON.parse(value) as CashShiftRecord;
  } catch {
    return null;
  }
}

export function parseDailyClosingRecord(value: string): DailyClosingRecord | null {
  try {
    return JSON.parse(value) as DailyClosingRecord;
  } catch {
    return null;
  }
}
