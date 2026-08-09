import { Decimal } from '@prisma/client/runtime/library';
import { ExpenseDetailRecord, ExpenseListRecord } from './expense.select';
import {
  decodeExpenseDescription,
  ExpenseApprovalStatus,
} from './utils/expense-meta.util';

export interface ExpenseResponse {
  id: string;
  referenceNumber: string | null;
  title: string;
  description: string | null;
  amount: number;
  expenseDate: Date;
  receiptPhotoUrl: string | null;
  approvalStatus: ExpenseApprovalStatus | null;
  approvedByEmployeeId: string | null;
  approvedAt: string | null;
  category: {
    id: string;
    code: string;
    name: string;
  };
  createdBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedExpenses {
  items: ExpenseResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

function decimalToNumber(value: Decimal | number): number {
  return Number(value);
}

export function toExpenseResponse(
  expense: ExpenseListRecord | ExpenseDetailRecord,
): ExpenseResponse {
  const { meta, description } = decodeExpenseDescription(expense.description);

  return {
    id: expense.id,
    referenceNumber: meta?.referenceNumber ?? null,
    title: expense.title,
    description,
    amount: decimalToNumber(expense.amount),
    expenseDate: expense.expenseDate,
    receiptPhotoUrl: expense.receiptPhotoUrl,
    approvalStatus: meta?.approvalStatus ?? null,
    approvedByEmployeeId: meta?.approvedByEmployeeId ?? null,
    approvedAt: meta?.approvedAt ?? null,
    category: expense.expenseCategory,
    createdBy: expense.employee,
    createdAt: expense.createdAt,
    updatedAt: expense.updatedAt,
  };
}
