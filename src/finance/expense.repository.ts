import { Injectable } from '@nestjs/common';
import { CashflowType, Prisma, ReferenceType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { ExpenseQueryDto } from './dto/expense.dto';
import {
  expenseDetailSelect,
  expenseListSelect,
  ExpenseDetailRecord,
} from './expense.select';
import {
  decodeExpenseDescription,
  encodeExpenseDescription,
  ExpenseFinancialMeta,
} from './utils/expense-meta.util';
import { FinanceSettingsRepository } from './finance-settings.repository';

export interface CreateExpenseInput {
  expenseCategoryId: string;
  employeeId: string;
  title: string;
  description?: string | null;
  amount: number;
  expenseDate: Date;
  receiptPhotoUrl?: string | null;
  meta: ExpenseFinancialMeta;
}

export interface UpdateExpenseInput {
  expenseCategoryId?: string;
  title?: string;
  description?: string | null;
  amount?: number;
  expenseDate?: Date;
  receiptPhotoUrl?: string | null;
  meta?: ExpenseFinancialMeta;
}

@Injectable()
export class ExpenseRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly financeSettings: FinanceSettingsRepository,
  ) {}

  findMany(query: ExpenseQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);

    return this.prisma.$transaction([
      this.prisma.expense.findMany({
        where,
        skip,
        take: limit,
        orderBy: { expenseDate: 'desc' },
        select: expenseListSelect,
      }),
      this.prisma.expense.count({ where }),
    ]);
  }

  findById(id: string): Promise<ExpenseDetailRecord | null> {
    return this.prisma.expense.findFirst({
      where: { id, deletedAt: null },
      select: expenseDetailSelect,
    });
  }

  findCategoryByCode(code: string) {
    return this.prisma.expenseCategory.findFirst({
      where: { code, isActive: true, deletedAt: null },
      select: { id: true, code: true, name: true },
    });
  }

  findCategories() {
    return this.prisma.expenseCategory.findMany({
      where: { isActive: true, deletedAt: null },
      select: { id: true, code: true, name: true },
      orderBy: { name: 'asc' },
    });
  }

  createExpense(input: CreateExpenseInput): Promise<ExpenseDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const expense = await tx.expense.create({
        data: {
          expenseCategoryId: input.expenseCategoryId,
          employeeId: input.employeeId,
          title: input.title,
          description: encodeExpenseDescription(
            input.meta,
            input.description,
          ),
          amount: input.amount,
          expenseDate: input.expenseDate,
          receiptPhotoUrl: input.receiptPhotoUrl,
        },
        select: expenseDetailSelect,
      });

      if (input.meta.approvalStatus === 'APPROVED') {
        await tx.cashflow.create({
          data: {
            type: CashflowType.EXPENSE,
            referenceType: ReferenceType.EXPENSE,
            referenceId: expense.id,
            amount: input.amount,
            transactionDate: input.expenseDate,
            description: `${input.meta.referenceNumber} | ${input.title}`,
            createdByEmployeeId: input.employeeId,
          },
        });
      }

      return expense;
    });
  }

  updateExpense(
    id: string,
    input: UpdateExpenseInput,
    approverId?: string,
  ): Promise<ExpenseDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.expense.findFirst({
        where: { id, deletedAt: null },
        select: {
          id: true,
          amount: true,
          title: true,
          expenseDate: true,
          description: true,
          employeeId: true,
        },
      });

      if (!existing) {
        throw new Error('NOT_FOUND');
      }

      const { meta: existingMeta } = decodeExpenseDescription(
        existing.description,
      );

      if (
        existingMeta?.approvalStatus === 'APPROVED' &&
        (input.amount !== undefined || input.title !== undefined)
      ) {
        throw new Error('FINALIZED');
      }

      const nextMeta = input.meta ?? existingMeta;
      const nextDescription = encodeExpenseDescription(
        nextMeta!,
        input.description ??
          decodeExpenseDescription(existing.description).description,
      );

      const expense = await tx.expense.update({
        where: { id },
        data: {
          ...(input.expenseCategoryId
            ? { expenseCategoryId: input.expenseCategoryId }
            : {}),
          ...(input.title ? { title: input.title } : {}),
          ...(input.amount !== undefined ? { amount: input.amount } : {}),
          ...(input.expenseDate ? { expenseDate: input.expenseDate } : {}),
          ...(input.receiptPhotoUrl !== undefined
            ? { receiptPhotoUrl: input.receiptPhotoUrl }
            : {}),
          description: nextDescription,
        },
        select: expenseDetailSelect,
      });

      if (
        nextMeta?.approvalStatus === 'APPROVED' &&
        existingMeta?.approvalStatus !== 'APPROVED'
      ) {
        await tx.cashflow.create({
          data: {
            type: CashflowType.EXPENSE,
            referenceType: ReferenceType.EXPENSE,
            referenceId: expense.id,
            amount: Number(expense.amount),
            transactionDate: expense.expenseDate,
            description: `${nextMeta.referenceNumber} | ${expense.title}`,
            createdByEmployeeId: approverId ?? existing.employeeId,
          },
        });
      }

      return expense;
    });
  }

  softDelete(id: string): Promise<ExpenseDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.expense.findFirst({
        where: { id, deletedAt: null },
        select: { id: true, description: true },
      });

      if (!existing) {
        throw new Error('NOT_FOUND');
      }

      const { meta } = decodeExpenseDescription(existing.description);

      if (meta?.approvalStatus === 'APPROVED') {
        throw new Error('FINALIZED');
      }

      return tx.expense.update({
        where: { id },
        data: { deletedAt: new Date() },
        select: expenseDetailSelect,
      });
    });
  }

  private buildWhereClause(query: ExpenseQueryDto): Prisma.ExpenseWhereInput {
    const where: Prisma.ExpenseWhereInput = { deletedAt: null };

    if (query.categoryCode) {
      where.expenseCategory = { code: query.categoryCode };
    }

    if (query.dateFrom || query.dateTo) {
      where.expenseDate = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    if (query.search) {
      const search = query.search.trim();
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    return where;
  }
}
