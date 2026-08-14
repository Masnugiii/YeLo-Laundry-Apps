import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { RoleResponseDto } from './dto/role-response.dto';
import { PermissionService } from './permission.service';

@ApiTags('Roles')
@ApiBearerAuth('access-token')
@Controller('roles')
export class RoleController {
  constructor(private readonly permissionService: PermissionService) {}

  @Get()
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'List all internal staff roles' })
  @ApiResponse({
    status: 200,
    description: 'Roles retrieved successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  findAll(): Promise<ApiSuccessResponse<RoleResponseDto[]>> {
    return this.permissionService.findAllRoles();
  }
}
