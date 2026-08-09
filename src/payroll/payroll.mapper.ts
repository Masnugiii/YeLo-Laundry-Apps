import {
  PayrollBonus,
  PayrollDeduction,
  PayrollPayment,
  PayrollRecord,
  PayrollApprovalEvent,
  Employee,
} from '@prisma/client';

export type PayrollRecordWithRelations = PayrollRecord & {
  employee: Pick<Employee, 'id' | 'employeeCode' | 'fullName' | 'position'>;
  bonuses: PayrollBonus[];
  deductions: PayrollDeduction[];
  approvalHistory: (PayrollApprovalEvent & {
    actor: Pick<Employee, 'id' | 'fullName' | 'employeeCode'>;
  })[];
  payments: (PayrollPayment & {
    paidBy: Pick<Employee, 'id' | 'fullName' | 'employeeCode'>;
  })[];
};

function decimal(value: { toString(): string } | number): number {
  return Number(value);
}

export function toPayrollListItem(record: PayrollRecordWithRelations) {
  return {
    id: record.id,
    payrollNumber: record.payrollNumber,
    employeeId: record.employeeId,
    employeeName: record.employee.fullName,
    employeeCode: record.employee.employeeCode,
    role: record.role,
    periodStart: record.periodStart,
    periodEnd: record.periodEnd,
    productionKg: decimal(record.laundryKg) + decimal(record.ironingKg),
    productionItems: decimal(record.laundryPiece) + decimal(record.ironingPiece),
    laundryKg: decimal(record.laundryKg),
    laundryPiece: decimal(record.laundryPiece),
    ironingKg: decimal(record.ironingKg),
    ironingPiece: decimal(record.ironingPiece),
    attendanceDays: record.presentDays,
    bonus: decimal(record.totalBonus),
    deduction: decimal(record.totalDeduction),
    grossSalary: decimal(record.grossSalary),
    netSalary: decimal(record.netSalary),
    status: record.status,
  };
}

export function toPayrollDetail(record: PayrollRecordWithRelations) {
  return {
    ...toPayrollListItem(record),
    position: record.employee.position,
    ordersFinished: record.ordersFinished,
    productionSalary: decimal(record.productionSalary),
    baseSalary: decimal(record.baseSalary),
    attendance: {
      present: record.presentDays,
      absent: record.absentDays,
      late: record.lateDays,
      leave: record.leaveDays,
    },
    production: {
      laundryKg: decimal(record.laundryKg),
      laundryPiece: decimal(record.laundryPiece),
      ironingKg: decimal(record.ironingKg),
      ironingPiece: decimal(record.ironingPiece),
      ordersFinished: record.ordersFinished,
    },
    bonuses: record.bonuses.map((bonus) => ({
      id: bonus.id,
      type: bonus.type,
      amount: decimal(bonus.amount),
      notes: bonus.notes,
      createdAt: bonus.createdAt,
    })),
    deductions: record.deductions.map((deduction) => ({
      id: deduction.id,
      type: deduction.type,
      amount: decimal(deduction.amount),
      notes: deduction.notes,
      createdAt: deduction.createdAt,
    })),
    approvalHistory: record.approvalHistory.map((event) => ({
      id: event.id,
      status: event.status,
      notes: event.notes,
      actor: event.actor,
      createdAt: event.createdAt,
    })),
    paymentHistory: record.payments.map((payment) => ({
      id: payment.id,
      method: payment.method,
      amount: decimal(payment.amount),
      referenceNumber: payment.referenceNumber,
      notes: payment.notes,
      paidAt: payment.paidAt,
      paidBy: payment.paidBy,
    })),
    calculatedAt: record.calculatedAt,
    approvedAt: record.approvedAt,
    paidAt: record.paidAt,
  };
}
