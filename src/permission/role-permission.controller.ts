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
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AssignPermissionsDto } from './dto/assign-permissions.dto';
import { PermissionResponseDto } from './dto/permission-response.dto';
import { PermissionService } from './permission.service';

@ApiTags('Role Permissions')
@ApiBearerAuth('access-token')
@Controller('roles/:roleId/permissions')
export class RolePermissionController {
  constructor(private readonly permissionService: PermissionService) {}

  @Get()
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Get all permissions assigned to a role' })
  @ApiParam({ name: 'roleId', description: 'Role UUID' })
  @ApiResponse({
    status: 200,
    description: 'Role permissions retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Role permissions retrieved successfully',
        data: [
          {
            id: '550e8400-e29b-41d4-a716-446655440001',
            code: 'employee.view',
            name: 'View Employee',
            module: 'employee',
            description: 'Allows viewing employee records',
          },
        ],
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Role not found' })
  getRolePermissions(
    @Param('roleId', ParseUUIDPipe) roleId: string,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    return this.permissionService.getRolePermissions(roleId);
  }

  @Post()
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Replace all permissions assigned to a role' })
  @ApiParam({ name: 'roleId', description: 'Role UUID' })
  @ApiBody({
    type: AssignPermissionsDto,
    examples: {
      default: {
        summary: 'Assign multiple permissions',
        value: {
          permissionIds: [
            '550e8400-e29b-41d4-a716-446655440001',
            '550e8400-e29b-41d4-a716-446655440002',
          ],
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Role permissions updated successfully',
    schema: {
      example: {
        success: true,
        message: 'Role permissions updated successfully',
        data: [
          {
            id: '550e8400-e29b-41d4-a716-446655440001',
            code: 'employee.view',
            name: 'View Employee',
            module: 'employee',
          },
        ],
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid request or inactive permission' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Role or permission not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  assignPermissions(
    @Param('roleId', ParseUUIDPipe) roleId: string,
    @Body() dto: AssignPermissionsDto,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    return this.permissionService.assignPermissions(roleId, dto);
  }

  @Delete(':permissionId')
  @Roles(ROLES.OWNER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove a single permission from a role' })
  @ApiParam({ name: 'roleId', description: 'Role UUID' })
  @ApiParam({ name: 'permissionId', description: 'Permission UUID to remove' })
  @ApiResponse({
    status: 200,
    description: 'Permission removed successfully',
    schema: {
      example: {
        success: true,
        message: 'Permission removed successfully',
        data: null,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Role or permission assignment not found' })
  removePermission(
    @Param('roleId', ParseUUIDPipe) roleId: string,
    @Param('permissionId', ParseUUIDPipe) permissionId: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.permissionService.removePermission(roleId, permissionId);
  }
}
