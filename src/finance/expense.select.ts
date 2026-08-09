import { Prisma } from '@prisma/client';

const employeeSummarySelect = {
  id: true,
  fullName: true,
  employeeCode: true,
} satisfies Prisma.EmployeeSelect;

export const expenseListSelect = {
  id: true,
  expenseCategoryId: true,
  employeeId: true,
  title: true,
  description: true,
  amount: true,
  expenseDate: true,
  receiptPhotoUrl: true,
  createdAt: true,
  updatedAt: true,
  expenseCategory: {
    select: {
      id: true,
      code: true,
      name: true,
    },
  },
  employee: { select: employeeSummarySelect },
} satisfies Prisma.ExpenseSelect;

export const expenseDetailSelect = expenseListSelect;

export type ExpenseListRecord = Prisma.ExpenseGetPayload<{
  select: typeof expenseListSelect;
}>;

export type ExpenseDetailRecord = Prisma.ExpenseGetPayload<{
  select: typeof expenseDetailSelect;
}>;
