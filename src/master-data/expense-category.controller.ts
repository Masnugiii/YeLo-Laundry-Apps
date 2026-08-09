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
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { OwnerWriteGuard } from '../settings/guards/owner-write.guard';
import {
  CreateExpenseCategoryDto,
  UpdateExpenseCategoryDto,
} from './master-data.dto';
import { ExpenseCategoryService } from './expense-category.service';

@ApiTags('Expense Categories')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('expense-categories')
export class ExpenseCategoryController {
  constructor(
    private readonly expenseCategoryService: ExpenseCategoryService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List expense categories' })
  async list(@Query('includeInactive') includeInactive?: string) {
    const data = await this.expenseCategoryService.list(
      includeInactive === 'true',
    );
    return {
      success: true,
      message: 'Expense categories retrieved successfully',
      data,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get expense category detail' })
  async getOne(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.expenseCategoryService.getById(id);
    return {
      success: true,
      message: 'Expense category retrieved successfully',
      data,
    };
  }

  @Post()
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create expense category (OWNER only)' })
  async create(
    @Body() dto: CreateExpenseCategoryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.expenseCategoryService.create(
      dto,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Expense category created successfully',
      data,
    };
  }

  @Patch(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update expense category (OWNER only)' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateExpenseCategoryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.expenseCategoryService.update(
      id,
      dto,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Expense category updated successfully',
      data,
    };
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete expense category (OWNER only)' })
  async delete(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.expenseCategoryService.delete(id, user.employeeId);
    return {
      success: true,
      message: 'Expense category deleted successfully',
      data,
    };
  }
}
