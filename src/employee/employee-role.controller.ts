import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
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
import { AssignEmployeeRolesDto } from './dto/assign-employee-roles.dto';
import { EmployeeRoleResponseDto } from './dto/employee-role-response.dto';
import { EmployeeRoleService } from './employee-role.service';

@ApiTags('Employee Roles')
@ApiBearerAuth('access-token')
@Controller('employees/:employeeId/roles')
export class EmployeeRoleController {
  constructor(private readonly employeeRoleService: EmployeeRoleService) {}

  @Get()
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Get all roles assigned to an employee' })
  @ApiParam({ name: 'employeeId', description: 'Employee UUID' })
  @ApiResponse({
    status: 200,
    description: 'Employee roles retrieved successfully',
    schema: {
      example: {
        success: true,
        data: [
          {
            id: '550e8400-e29b-41d4-a716-446655440001',
            code: 'CASHIER',
            name: 'Kasir',
          },
          {
            id: '550e8400-e29b-41d4-a716-446655440002',
            code: 'BINATU',
            name: 'Binatu',
          },
        ],
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee not found' })
  getRoles(
    @Param('employeeId', ParseUUIDPipe) employeeId: string,
  ): Promise<ApiSuccessResponse<EmployeeRoleResponseDto[]>> {
    return this.employeeRoleService.getEmployeeRoles(employeeId);
  }

  @Post()
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Replace all role assignments for an employee' })
  @ApiParam({ name: 'employeeId', description: 'Employee UUID' })
  @ApiBody({
    type: AssignEmployeeRolesDto,
    examples: {
      default: {
        summary: 'Assign multiple roles',
        value: {
          roleIds: [
            '550e8400-e29b-41d4-a716-446655440001',
            '550e8400-e29b-41d4-a716-446655440002',
          ],
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Employee roles updated successfully',
    schema: {
      example: {
        success: true,
        message: 'Employee roles updated successfully',
        data: [
          {
            id: '550e8400-e29b-41d4-a716-446655440001',
            code: 'CASHIER',
            name: 'Kasir',
          },
        ],
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid request or inactive employee/role' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee or role not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  assignRoles(
    @Param('employeeId', ParseUUIDPipe) employeeId: string,
    @Body() dto: AssignEmployeeRolesDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<EmployeeRoleResponseDto[]>> {
    return this.employeeRoleService.assignRoles(
      employeeId,
      dto,
      user.employeeId,
    );
  }

  @Delete(':roleId')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove a single role from an employee' })
  @ApiParam({ name: 'employeeId', description: 'Employee UUID' })
  @ApiParam({ name: 'roleId', description: 'Role UUID to remove' })
  @ApiResponse({
    status: 200,
    description: 'Role removed successfully',
    schema: {
      example: {
        success: true,
        message: 'Role removed successfully',
        data: null,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Employee or role assignment not found' })
  removeRole(
    @Param('employeeId', ParseUUIDPipe) employeeId: string,
    @Param('roleId', ParseUUIDPipe) roleId: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.employeeRoleService.removeRole(employeeId, roleId);
  }
}
