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
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  AssignDriverDto,
  DeliverySuccessDto,
  PickupSuccessDto,
  TripLocationDto,
} from './dto/pickup-delivery.dto';
import {
  JobDetailResponse,
  PickupDeliveryDashboard,
} from './pickup-delivery.mapper';
import { PickupDeliveryService } from './pickup-delivery.service';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const ASSIGN_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;
const DRIVER_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER] as const;

const JOB_EXAMPLE = {
  id: 'cc0e8400-e29b-41d4-a716-446655440050',
  jobType: 'PICKUP',
  orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
  status: 'ASSIGNED',
};

@ApiTags('Pickup & Delivery')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.PICKUP)
@Controller('pickup-delivery')
export class PickupDeliveryController {
  constructor(private readonly service: PickupDeliveryService) {}

  @Get('dashboard')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get pickup & delivery dashboard' })
  @ApiResponse({
    status: 200,
    description: 'Dashboard retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Pickup & delivery dashboard retrieved successfully',
        data: {
          pickupRequested: 5,
          driverAssigned: 3,
          onTheWay: 2,
          readyForDelivery: 4,
          deliveredToday: 6,
          failedDelivery: 1,
          averageDeliveryTimeMinutes: 42,
        },
      },
    },
  })
  getDashboard(): Promise<ApiSuccessResponse<PickupDeliveryDashboard>> {
    return this.service.getDashboard();
  }

  @Get(':id')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get pickup or delivery job detail' })
  @ApiParam({ name: 'id', description: 'Pickup or delivery job UUID' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.findJobDetail(id);
  }

  @Post(':id/assign-driver')
  @Roles(...ASSIGN_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Assign driver to pickup or delivery job' })
  @ApiParam({ name: 'id', description: 'Job UUID' })
  @ApiBody({
    type: AssignDriverDto,
    examples: {
      default: {
        summary: 'Assign driver',
        value: {
          driverId: '660e8400-e29b-41d4-a716-446655440003',
          estimatedDistanceKm: 5.2,
          estimatedDurationMinutes: 25,
        },
      },
    },
  })
  assignDriver(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AssignDriverDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.assignDriver(id, dto, user.employeeId, user.roles);
  }

  @Post(':id/start-trip')
  @Roles(...DRIVER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start pickup or delivery trip' })
  @ApiParam({ name: 'id', description: 'Job UUID' })
  @ApiBody({ type: TripLocationDto })
  startTrip(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: TripLocationDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.startTrip(id, dto, user.employeeId, user.roles);
  }

  @Post(':id/arrived')
  @Roles(...DRIVER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark driver arrived at location' })
  @ApiParam({ name: 'id', description: 'Job UUID' })
  @ApiBody({ type: TripLocationDto })
  arrived(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: TripLocationDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.arrived(id, dto, user.employeeId, user.roles);
  }

  @Post(':id/pickup-success')
  @Roles(...DRIVER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Complete pickup with proof photo' })
  @ApiParam({ name: 'id', description: 'Pickup job UUID' })
  @ApiBody({
    type: PickupSuccessDto,
    examples: {
      default: {
        summary: 'Pickup proof',
        value: {
          photoUrl: 'https://cdn.example.com/pickup-proof.jpg',
          notes: 'Laundry received successfully.',
        },
      },
    },
  })
  pickupSuccess(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PickupSuccessDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.pickupSuccess(id, dto, user.employeeId, user.roles);
  }

  @Post(':id/delivery-success')
  @Roles(...DRIVER_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Complete delivery with proof photo' })
  @ApiParam({ name: 'id', description: 'Delivery job UUID' })
  @ApiBody({
    type: DeliverySuccessDto,
    examples: {
      default: {
        summary: 'Delivery proof',
        value: {
          photoUrl: 'https://cdn.example.com/delivery-proof.jpg',
          receiverName: 'Budi',
          notes: 'Delivered successfully.',
        },
      },
    },
  })
  deliverySuccess(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: DeliverySuccessDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    return this.service.deliverySuccess(id, dto, user.employeeId, user.roles);
  }
}
