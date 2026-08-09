import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
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
import { DriverTasksDashboard } from './pickup-delivery.mapper';
import { PickupDeliveryService } from './pickup-delivery.service';

@ApiTags('Drivers')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.PICKUP, PERMISSIONS.DELIVERY)
@Controller('drivers')
export class DriverController {
  constructor(private readonly service: PickupDeliveryService) {}

  @Get('me/tasks')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER)
  @ApiOperation({ summary: 'Get current driver tasks dashboard' })
  @ApiResponse({
    status: 200,
    description: 'Driver tasks retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Driver tasks retrieved successfully',
        data: {
          todayPickups: [],
          todayDeliveries: [],
          completedTasks: 2,
          pendingTasks: 3,
        },
      },
    },
  })
  getMyTasks(
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<DriverTasksDashboard>> {
    return this.service.getDriverTasks(user.employeeId);
  }
}
