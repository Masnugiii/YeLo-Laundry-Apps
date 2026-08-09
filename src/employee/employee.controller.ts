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
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { EmployeeQueryDto } from './dto/employee-query.dto';
import { EmployeeStatisticsDto } from './dto/employee-statistics.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import { EmployeeResponse, PaginatedEmployees } from './employee.mapper';
import { EmployeeService } from './employee.service';
import { ProfileService } from './profile.service';

@ApiTags('Employees')
@ApiBearerAuth('access-token')
@Controller('employees')
export class EmployeeController {
  constructor(
    private readonly employeeService: EmployeeService,
    private readonly profileService: ProfileService,
  ) {}

  @Get('statistics')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({ summary: 'Get employee statistics' })
  @ApiResponse({
    status: 200,
    description: 'Employee statistics retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Employee statistics retrieved successfully',
        data: {
          totalEmployees: 25,
          activeEmployees: 20,
          inactiveEmployees: 3,
          managers: 2,
          cashiers: 5,
          operators: 4,
          drivers: 3,
          binatu: 6,
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  getStatistics(): Promise<ApiSuccessResponse<EmployeeStatisticsDto>> {
    return this.employeeService.getStatistics();
  }

  @Get()
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({
    summary: 'List employees with advanced search, filtering, sorting, and pagination',
  })
  @ApiResponse({ status: 200, description: 'Employees retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  findAll(
    @Query() query: EmployeeQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedEmployees>> {
    return this.employeeService.findAll(query);
  }

  @Post()
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new employee' })
  @ApiResponse({ status: 201, description: 'Employee created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 409, description: 'Duplicate employee code, phone, or email' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  create(
    @Body() dto: CreateEmployeeDto,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    return this.employeeService.create(dto);
  }

  @Get(':id')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({ summary: 'Get employee detail by ID' })
  @ApiParam({ name: 'id', description: 'Employee UUID' })
  @ApiResponse({ status: 200, description: 'Employee retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    return this.employeeService.findOne(id);
  }

  @Patch(':id')
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Update an employee' })
  @ApiParam({ name: 'id', description: 'Employee UUID' })
  @ApiResponse({ status: 200, description: 'Employee updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  @ApiResponse({ status: 409, description: 'Duplicate employee code, phone, or email' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateEmployeeDto,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    return this.employeeService.update(id, dto);
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete an employee' })
  @ApiParam({ name: 'id', description: 'Employee UUID' })
  @ApiResponse({ status: 200, description: 'Employee deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete self or last owner' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<null>> {
    return this.employeeService.remove(id, user.employeeId);
  }

  @Post(':id/restore')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Restore a soft-deleted employee' })
  @ApiParam({ name: 'id', description: 'Employee UUID' })
  @ApiResponse({ status: 200, description: 'Employee restored successfully' })
  @ApiResponse({ status: 400, description: 'Employee is not deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  @ApiResponse({ status: 409, description: 'Duplicate employee code, phone, or email' })
  restore(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    return this.employeeService.restore(id);
  }

  @Post(':id/reset-password')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reset employee password (OWNER only)' })
  @ApiParam({ name: 'id', description: 'Employee UUID' })
  @ApiBody({
    type: ResetPasswordDto,
    examples: {
      default: {
        summary: 'Reset password',
        value: { newPassword: 'Admin123!' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Password reset successfully' })
  @ApiResponse({ status: 400, description: 'New password same as current' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  resetPassword(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResetPasswordDto,
  ): Promise<ApiSuccessResponse<null>> {
    return this.profileService.resetPassword(id, dto);
  }
}
