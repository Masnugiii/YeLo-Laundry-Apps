import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('RBAC Samples')
@ApiBearerAuth('access-token')
@Controller()
export class RbacSampleController {
  @Get('admin')
  @Roles(ROLES.OWNER)
  @ApiOperation({ summary: 'Admin area — OWNER only' })
  @ApiResponse({ status: 200, description: 'Access granted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  admin() {
    return {
      success: true,
      message: 'Owner admin access granted',
      data: { resource: 'admin' },
    };
  }

  @Get('reports')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({ summary: 'Reports area — OWNER or MANAGER' })
  @ApiResponse({ status: 200, description: 'Access granted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  reports() {
    return {
      success: true,
      message: 'Reports access granted',
      data: { resource: 'reports' },
    };
  }

  @Get('operator')
  @Roles(ROLES.OPERATOR)
  @ApiOperation({ summary: 'Operator area — OPERATOR only' })
  @ApiResponse({ status: 200, description: 'Access granted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  operator() {
    return {
      success: true,
      message: 'Operator access granted',
      data: { resource: 'operator' },
    };
  }

  @Get('binatu')
  @Roles(ROLES.BINATU)
  @ApiOperation({ summary: 'Binatu area — BINATU only' })
  @ApiResponse({ status: 200, description: 'Access granted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  binatu() {
    return {
      success: true,
      message: 'Binatu access granted',
      data: { resource: 'binatu' },
    };
  }

  @Get('driver')
  @Roles(ROLES.DRIVER)
  @ApiOperation({ summary: 'Driver area — DRIVER only' })
  @ApiResponse({ status: 200, description: 'Access granted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  driver() {
    return {
      success: true,
      message: 'Driver access granted',
      data: { resource: 'driver' },
    };
  }
}
