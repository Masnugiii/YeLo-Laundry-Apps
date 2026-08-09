export type PayrollRecordStatus = "DRAFT" | "CALCULATED" | "APPROVED" | "PAID";
export type PayrollPeriodType = "weekly" | "biweekly" | "monthly";
export type PayrollPaymentMethod = "CASH" | "TRANSFER" | "WALLET";

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

export interface PayrollDashboard {
  currentPeriod: { start: string; end: string };
  employeesWaitingPayroll: number;
  estimatedPayroll: number;
  paidPayroll: number;
  totalBonus: number;
  totalDeduction: number;
}

export interface PayrollListItem {
  id: string;
  payrollNumber: string;
  employeeId: string;
  employeeName: string;
  employeeCode: string;
  role: string;
  periodStart: string;
  periodEnd: string;
  productionKg: number;
  productionItems: number;
  laundryKg: number;
  laundryPiece: number;
  ironingKg: number;
  ironingPiece: number;
  attendanceDays: number;
  bonus: number;
  deduction: number;
  grossSalary: number;
  netSalary: number;
  status: PayrollRecordStatus;
}

export interface PayrollDetail extends PayrollListItem {
  position: string;
  ordersFinished: number;
  productionSalary: number;
  baseSalary: number;
  attendance: {
    present: number;
    absent: number;
    late: number;
    leave: number;
  };
  production: {
    laundryKg: number;
    laundryPiece: number;
    ironingKg: number;
    ironingPiece: number;
    ordersFinished: number;
  };
  bonuses: Array<{
    id: string;
    type: string;
    amount: number;
    notes: string | null;
    createdAt: string;
  }>;
  deductions: Array<{
    id: string;
    type: string;
    amount: number;
    notes: string | null;
    createdAt: string;
  }>;
  approvalHistory: Array<{
    id: string;
    status: PayrollRecordStatus;
    notes: string | null;
    actor: { id: string; fullName: string; employeeCode: string };
    createdAt: string;
  }>;
  paymentHistory: Array<{
    id: string;
    method: PayrollPaymentMethod;
    amount: number;
    referenceNumber: string | null;
    notes: string | null;
    paidAt: string;
    paidBy: { id: string; fullName: string; employeeCode: string };
  }>;
  calculatedAt: string | null;
  approvedAt: string | null;
  paidAt: string | null;
}

export interface PayrollListParams {
  page?: number;
  limit?: number;
  employeeId?: string;
  role?: string;
  status?: PayrollRecordStatus;
  periodStart?: string;
  periodEnd?: string;
}
