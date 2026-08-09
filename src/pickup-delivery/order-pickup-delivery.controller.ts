import {
  Body,
  Controller,
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
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  RequestDeliveryDto,
  RequestPickupDto,
} from './dto/pickup-delivery.dto';
import { JobDetailResponse } from './pickup-delivery.mapper';
import { PickupDeliveryService } from './pickup-delivery.service';

const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;

@ApiTags('Order Pickup & Delivery')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.PICKUP, PERMISSIONS.DELIVERY)
@Controller('orders')
export class OrderPickupDeliveryController {
  constructor(private readonly service: PickupDeliveryService) {}

  @Post(':orderId/request-pickup')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Request pickup for an order' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({
    type: RequestPickupDto,
    examples: {
      default: {
        summary: 'Schedule pickup',
        value: {
          scheduledPickupAt: '2026-08-08T10:00:00.000Z',
          notes: 'Pickup from home',
        },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'Pickup requested successfully' })
  requestPickup(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: RequestPickupDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.requestPickup(orderId, dto, user.employeeId);
  }

  @Post(':orderId/request-delivery')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Request delivery for an order' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({
    type: RequestDeliveryDto,
    examples: {
      default: {
        summary: 'Schedule delivery',
        value: {
          scheduledDeliveryAt: '2026-08-10T14:00:00.000Z',
          notes: 'Deliver after 2 PM',
        },
      },
    },
  })
  requestDelivery(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: RequestDeliveryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.requestDelivery(orderId, dto, user.employeeId);
  }
}
