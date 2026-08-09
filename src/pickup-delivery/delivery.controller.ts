import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { JobQueryDto } from './dto/pickup-delivery.dto';
import { PaginatedJobs } from './pickup-delivery.mapper';
import { PickupDeliveryService } from './pickup-delivery.service';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

@ApiTags('Deliveries')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.DELIVERY)
@Controller('deliveries')
export class DeliveryController {
  constructor(private readonly service: PickupDeliveryService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List delivery jobs' })
  @ApiResponse({ status: 200, description: 'Delivery jobs retrieved successfully' })
  findAll(
    @Query() query: JobQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedJobs>> {
    return this.service.findDeliveries(query);
  }
}
