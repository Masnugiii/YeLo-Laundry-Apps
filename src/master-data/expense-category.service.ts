import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import {
  CreateExpenseCategoryDto,
  UpdateExpenseCategoryDto,
} from './master-data.dto';

@Injectable()
export class ExpenseCategoryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async list(includeInactive = false) {
    return this.prisma.expenseCategory.findMany({
      where: {
        deletedAt: null,
        ...(includeInactive ? {} : { isActive: true }),
      },
      orderBy: { name: 'asc' },
    });
  }

  async getById(id: string) {
    const category = await this.prisma.expenseCategory.findFirst({
      where: { id, deletedAt: null },
    });

    if (!category) {
      throw new NotFoundException('Expense category not found');
    }

    return category;
  }

  async create(dto: CreateExpenseCategoryDto, employeeId: string) {
    const existing = await this.prisma.expenseCategory.findFirst({
      where: { code: dto.code, deletedAt: null },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictException('Expense category code already exists');
    }

    const category = await this.prisma.expenseCategory.create({
      data: {
        code: dto.code,
        name: dto.name,
        description: dto.description,
        isActive: dto.isActive ?? true,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'expense_categories',
      action: 'expense_category_created',
      referenceId: category.id,
      after: category,
    });

    return category;
  }

  async update(
    id: string,
    dto: UpdateExpenseCategoryDto,
    employeeId: string,
  ) {
    const before = await this.getById(id);

    const category = await this.prisma.expenseCategory.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'expense_categories',
      action: 'expense_category_updated',
      referenceId: category.id,
      before,
      after: category,
    });

    return category;
  }

  async delete(id: string, employeeId: string) {
    const before = await this.getById(id);

    const category = await this.prisma.expenseCategory.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'expense_categories',
      action: 'expense_category_deleted',
      referenceId: category.id,
      before,
      after: category,
    });

    return category;
  }
}
