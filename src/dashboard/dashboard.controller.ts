import { Controller, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { DashboardService } from './dashboard.service';

@ApiTags('Dashboard')
@ApiBearerAuth('access-token')
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('summary')
  @Permissions(PERMISSIONS.DASHBOARD)
  @ApiOperation({ summary: 'Get consolidated dashboard summary metrics' })
  async getSummary() {
    const data = await this.dashboardService.getSummary();
    return {
      success: true,
      message: 'Dashboard summary loaded successfully',
      data,
    };
  }
}
