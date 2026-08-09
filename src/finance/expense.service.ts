import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { FinanceAuditService } from './finance-audit.service';
import { FinanceSettingsRepository } from './finance-settings.repository';
import {
  CreateExpenseDto,
  ExpenseQueryDto,
  UpdateExpenseDto,
} from './dto/expense.dto';
import { ExpenseRepository } from './expense.repository';
import {
  ExpenseResponse,
  PaginatedExpenses,
  toExpenseResponse,
} from './expense.mapper';
import { decodeExpenseDescription } from './utils/expense-meta.util';

@Injectable()
export class ExpenseService {
  constructor(
    private readonly expenseRepository: ExpenseRepository,
    private readonly financeSettings: FinanceSettingsRepository,
    private readonly auditService: FinanceAuditService,
  ) {}

  async findAll(
    query: ExpenseQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedExpenses>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [expenses, total] = await this.expenseRepository.findMany(query);

    return {
      success: true,
      message: 'Expenses retrieved successfully',
      data: {
        items: expenses.map(toExpenseResponse),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async listCategories(): Promise<
    ApiSuccessResponse<Array<{ id: string; code: string; name: string }>>
  > {
    const categories = await this.expenseRepository.findCategories();

    return {
      success: true,
      message: 'Expense categories retrieved successfully',
      data: categories,
    };
  }

  async create(
    dto: CreateExpenseDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    const category = await this.expenseRepository.findCategoryByCode(
      dto.categoryCode,
    );

    if (!category) {
      throw new BadRequestException('Expense category not found');
    }

    const autoApproveLimit =
      await this.financeSettings.getExpenseAutoApproveLimit();
    const referenceNumber =
      await this.financeSettings.generateReferenceNumber('EXP');
    const requiresApproval = dto.amount > autoApproveLimit;

    const expense = await this.expenseRepository.createExpense({
      expenseCategoryId: category.id,
      employeeId,
      title: dto.title,
      description: dto.description,
      amount: dto.amount,
      expenseDate: dto.expenseDate,
      receiptPhotoUrl: dto.receiptPhotoUrl,
      meta: {
        referenceNumber,
        approvalStatus: requiresApproval ? 'PENDING' : 'APPROVED',
        ...(requiresApproval
          ? {}
          : {
              approvedByEmployeeId: employeeId,
              approvedAt: new Date().toISOString(),
            }),
      },
    });

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'expense_created',
      referenceId: expense.id,
      description: `Expense ${referenceNumber} created`,
    });

    return {
      success: true,
      message: requiresApproval
        ? 'Expense created and pending approval'
        : 'Expense created successfully',
      data: toExpenseResponse(expense),
    };
  }

  async update(
    id: string,
    dto: UpdateExpenseDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    const existing = await this.expenseRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Expense not found');
    }

    const { meta, description } = decodeExpenseDescription(existing.description);

    if (!meta) {
      throw new BadRequestException('Expense metadata is invalid');
    }

    let nextMeta = { ...meta };

    if (dto.approvalAction) {
      if (meta.approvalStatus !== 'PENDING') {
        throw new BadRequestException('Expense is not pending approval');
      }

      if (dto.approvalAction === 'APPROVED') {
        nextMeta = {
          ...meta,
          approvalStatus: 'APPROVED',
          approvedByEmployeeId: employeeId,
          approvedAt: new Date().toISOString(),
        };
      } else {
        nextMeta = {
          ...meta,
          approvalStatus: 'REJECTED',
          approvedByEmployeeId: employeeId,
          approvedAt: new Date().toISOString(),
          rejectionReason: dto.rejectionReason,
        };
      }
    }

    let categoryId: string | undefined;

    if (dto.categoryCode) {
      const category = await this.expenseRepository.findCategoryByCode(
        dto.categoryCode,
      );

      if (!category) {
        throw new BadRequestException('Expense category not found');
      }

      categoryId = category.id;
    }

    let expense;

    try {
      expense = await this.expenseRepository.updateExpense(
        id,
        {
          expenseCategoryId: categoryId,
          title: dto.title,
          description: dto.description ?? description,
          amount: dto.amount,
          expenseDate: dto.expenseDate,
          receiptPhotoUrl: dto.receiptPhotoUrl,
          meta: nextMeta,
        },
        employeeId,
      );
    } catch (error) {
      if (error instanceof Error) {
        if (error.message === 'NOT_FOUND') {
          throw new NotFoundException('Expense not found');
        }

        if (error.message === 'FINALIZED') {
          throw new BadRequestException('Cannot edit approved expense');
        }
      }

      throw error;
    }

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: dto.approvalAction
        ? `expense_${dto.approvalAction.toLowerCase()}`
        : 'expense_updated',
      referenceId: expense.id,
      description: `Expense ${meta.referenceNumber} updated`,
    });

    return {
      success: true,
      message: 'Expense updated successfully',
      data: toExpenseResponse(expense),
    };
  }

  async remove(
    id: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    let expense;

    try {
      expense = await this.expenseRepository.softDelete(id);
    } catch (error) {
      if (error instanceof Error) {
        if (error.message === 'NOT_FOUND') {
          throw new NotFoundException('Expense not found');
        }

        if (error.message === 'FINALIZED') {
          throw new BadRequestException('Cannot delete approved expense');
        }
      }

      throw error;
    }

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'expense_deleted',
      referenceId: expense.id,
      description: `Expense ${expense.id} deleted`,
    });

    return {
      success: true,
      message: 'Expense deleted successfully',
      data: toExpenseResponse(expense),
    };
  }
}
