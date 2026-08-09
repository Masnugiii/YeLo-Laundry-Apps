import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
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
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AllowCustomerActor } from './decorators/allow-customer-actor.decorator';
import { CustomerDeviceItem } from './customer-device.mapper';
import { CustomerDeviceService } from './customer-device.service';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateDeviceDto } from './dto/update-device.dto';
import { CustomerDeviceViewGuard } from './guards/customer-device-view.guard';
import { CustomerSelfGuard } from './guards/customer-self.guard';
import { DevicePlatformApi } from './utils/customer-device-meta.util';

const DEVICE_RESPONSE_EXAMPLE = {
  id: 'dd0e8400-e29b-41d4-a716-446655440010',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  deviceName: 'Nugroho iPhone',
  devicePlatform: DevicePlatformApi.IOS,
  maskedDeviceToken: 'xxxx...xxxx',
  appVersion: '1.0.0',
  osVersion: '18.2',
  lastActiveAt: '2026-08-08T07:00:00.000Z',
  createdAt: '2026-08-08T06:00:00.000Z',
  updatedAt: '2026-08-08T07:00:00.000Z',
};

@ApiTags('Customer Devices')
@ApiBearerAuth('access-token')
@Controller('customers/:customerId/devices')
export class CustomerDeviceController {
  constructor(private readonly deviceService: CustomerDeviceService) {}

  @Get()
  @AllowCustomerActor()
  @UseGuards(CustomerDeviceViewGuard)
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @Permissions(PERMISSIONS.CUSTOMERS)
  @ApiOperation({
    summary: 'List active customer devices',
    description:
      'ERP Owner/Manager can view devices. Customers can view their own devices via Customer Mobile App. Device tokens are masked in responses.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer devices retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer devices retrieved successfully',
        data: [DEVICE_RESPONSE_EXAMPLE],
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  findAll(
    @Param('customerId', ParseUUIDPipe) customerId: string,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem[]>> {
    return this.deviceService.findAll(customerId);
  }

  @Get(':deviceId')
  @AllowCustomerActor()
  @UseGuards(CustomerDeviceViewGuard)
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @Permissions(PERMISSIONS.CUSTOMERS)
  @ApiOperation({ summary: 'Get a customer device by ID' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'deviceId', description: 'Device UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer device retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer device retrieved successfully',
        data: DEVICE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or device not found' })
  findOne(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    return this.deviceService.findOne(customerId, deviceId);
  }

  @Post()
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register a customer device',
    description:
      'Customer Mobile App only. Re-registers the same device token by updating the existing record. ERP employees cannot register devices.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: RegisterDeviceDto,
    examples: {
      default: {
        summary: 'iOS device registration',
        value: {
          deviceName: 'Nugroho iPhone',
          devicePlatform: DevicePlatformApi.IOS,
          deviceToken: 'xxxxxxxxxxxxxxxx',
          appVersion: '1.0.0',
          osVersion: '18.2',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Customer device registered successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer device registered successfully',
        data: DEVICE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — customer self only' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  register(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: RegisterDeviceDto,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    return this.deviceService.register(customerId, dto);
  }

  @Patch(':deviceId')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @ApiOperation({
    summary: 'Update a customer device',
    description: 'Customer Mobile App only. ERP employees cannot modify devices.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'deviceId', description: 'Device UUID' })
  @ApiBody({
    type: UpdateDeviceDto,
    examples: {
      default: {
        summary: 'Update push token',
        value: {
          deviceToken: 'yyyyyyyyyyyyyyyy',
          appVersion: '1.0.1',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Customer device updated successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer device updated successfully',
        data: DEVICE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — customer self only' })
  @ApiResponse({ status: 404, description: 'Customer or device not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  update(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
    @Body() dto: UpdateDeviceDto,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    return this.deviceService.update(customerId, deviceId, dto);
  }

  @Delete(':deviceId')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Unregister a customer device',
    description: 'Customer Mobile App only. Soft deletes the device record.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'deviceId', description: 'Device UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer device unregistered successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer device unregistered successfully',
        data: null,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — customer self only' })
  @ApiResponse({ status: 404, description: 'Customer or device not found' })
  remove(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('deviceId', ParseUUIDPipe) deviceId: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.deviceService.remove(customerId, deviceId);
  }
}
