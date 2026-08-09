import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CreateExpenseDto,
  ExpenseQueryDto,
  UpdateExpenseDto,
} from './dto/expense.dto';
import { ExpenseResponse, PaginatedExpenses } from './expense.mapper';
import { ExpenseService } from './expense.service';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR] as const;
const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;
const APPROVE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

const EXPENSE_EXAMPLE = {
  id: 'aa0e8400-e29b-41d4-a716-446655440030',
  referenceNumber: 'EXP-20260808-000001',
  title: 'Electricity bill August',
  amount: 350000,
  approvalStatus: 'APPROVED',
  expenseDate: '2026-08-08',
};

@ApiTags('Expenses')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE)
@Controller('expenses')
export class ExpenseController {
  constructor(private readonly expenseService: ExpenseService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List expenses with filters' })
  @ApiResponse({
    status: 200,
    description: 'Expenses retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Expenses retrieved successfully',
        data: {
          items: [EXPENSE_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: ExpenseQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedExpenses>> {
    return this.expenseService.findAll(query);
  }

  @Get('categories')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List expense categories' })
  listCategories() {
    return this.expenseService.listCategories();
  }

  @Post()
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create expense' })
  @ApiBody({
    type: CreateExpenseDto,
    examples: {
      default: {
        summary: 'Create utility expense',
        value: {
          categoryCode: 'ELECTRICITY',
          title: 'Electricity bill August',
          description: 'PLN monthly payment',
          amount: 350000,
          expenseDate: '2026-08-08',
        },
      },
    },
  })
  create(
    @Body() dto: CreateExpenseDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    return this.expenseService.create(dto, user.employeeId);
  }

  @Patch(':id')
  @Roles(...WRITE_ROLES, ...APPROVE_ROLES)
  @ApiOperation({
    summary: 'Update expense or approve/reject pending expense',
  })
  @ApiParam({ name: 'id', description: 'Expense UUID' })
  @ApiBody({ type: UpdateExpenseDto })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateExpenseDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    return this.expenseService.update(id, dto, user.employeeId);
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete expense (soft delete)' })
  @ApiParam({ name: 'id', description: 'Expense UUID' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ExpenseResponse>> {
    return this.expenseService.remove(id, user.employeeId);
  }
}
