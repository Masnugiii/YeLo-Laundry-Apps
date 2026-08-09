import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { PermissionQueryDto } from './dto/permission-query.dto';
import { PermissionResponseDto } from './dto/permission-response.dto';
import { PermissionService } from './permission.service';

@ApiTags('Permissions')
@ApiBearerAuth('access-token')
@Controller('permissions')
export class PermissionController {
  constructor(private readonly permissionService: PermissionService) {}

  @Get()
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'List all permissions with optional filters' })
  @ApiResponse({
    status: 200,
    description: 'Permissions retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Permissions retrieved successfully',
        data: [
          {
            id: '550e8400-e29b-41d4-a716-446655440000',
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
  findAll(
    @Query() query: PermissionQueryDto,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    return this.permissionService.findAll(query);
  }
}
