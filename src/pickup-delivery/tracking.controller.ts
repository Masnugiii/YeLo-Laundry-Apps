import {
  Body,
  Controller,
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
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ROLES } from '../auth/constants/roles.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { RecordTrackingDto } from './dto/pickup-delivery.dto';
import { PickupDeliveryService } from './pickup-delivery.service';

@ApiTags('Pickup & Delivery Tracking')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.PICKUP)
@Controller('pickup-delivery')
export class TrackingController {
  constructor(private readonly service: PickupDeliveryService) {}

  @Get(':id/tracking')
  @Roles(
    ROLES.OWNER,
    ROLES.MANAGER,
    ROLES.CASHIER,
    ROLES.OPERATOR,
    ROLES.BINATU,
    ROLES.DRIVER,
  )
  @ApiOperation({ summary: 'Get tracking history for a job' })
  @ApiParam({ name: 'id', description: 'Job UUID' })
  getTracking(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.getTracking(id);
  }

  @Post(':id/tracking')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Record GPS tracking point during trip' })
  @ApiParam({ name: 'id', description: 'Job UUID' })
  @ApiBody({ type: RecordTrackingDto })
  recordTracking(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RecordTrackingDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.service.recordTracking(id, dto, user.employeeId, user.roles);
  }
}
