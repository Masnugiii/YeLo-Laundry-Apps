export type PayrollPeriodType = 'weekly' | 'biweekly' | 'monthly';
export type PayrollRecordStatus = 'DRAFT' | 'CALCULATED' | 'APPROVED' | 'PAID';
export type PayrollBonusType = 'ATTENDANCE' | 'PERFORMANCE' | 'HOLIDAY' | 'MANUAL';
export type PayrollDeductionType = 'ADVANCE' | 'PENALTY' | 'LOAN' | 'OTHER';
export type PayrollPaymentMethod = 'CASH' | 'TRANSFER' | 'WALLET';

export interface PayrollSettings {
  laundryKgRate: number;
  laundryPieceRate: number;
  ironingKgRate: number;
  ironingPieceRate: number;
  attendanceBonusPerDay: number;
  managerWeeklySalary: number;
  operatorWeeklySalary: number;
  payrollScheduleDays: number[];
  periodType: PayrollPeriodType;
  attendanceBonus: {
    bonusAmount: number;
    requiredAttendance: number;
    allowedLate: number;
    allowedLeave: number;
    allowedAbsent: number;
  };
}

export interface ProductionSummary {
  laundryKg: number;
  laundryPiece: number;
  ironingKg: number;
  ironingPiece: number;
  ordersFinished: number;
  productionSalary: number;
}

export interface AttendanceSummary {
  presentDays: number;
  absentDays: number;
  lateDays: number;
  leaveDays: number;
}

export const PAYROLL_SETTINGS_KEY = 'payroll.settings';
export const PAYROLL_LATEST_TOTAL_KEY = 'payroll.latest_total';

export const DEFAULT_PAYROLL_SETTINGS: PayrollSettings = {
  laundryKgRate: 1000,
  laundryPieceRate: 2000,
  ironingKgRate: 1000,
  ironingPieceRate: 2000,
  attendanceBonusPerDay: 35000,
  managerWeeklySalary: 0,
  operatorWeeklySalary: 0,
  payrollScheduleDays: [1, 8, 16, 24],
  periodType: 'weekly',
  attendanceBonus: {
    bonusAmount: 35000,
    requiredAttendance: 0,
    allowedLate: 999,
    allowedLeave: 999,
    allowedAbsent: 999,
  },
};
