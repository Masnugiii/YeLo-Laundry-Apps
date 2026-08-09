import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentCustomer } from '../auth/decorators/current-customer.decorator';
import { AuthenticatedCustomer } from '../customer/interfaces/authenticated-customer.interface';
import { CustomerAppService } from './customer-app.service';
import {
  CustomerOrderQueryDto,
  CustomerPickupRequestDto,
  CustomerRewardQueryDto,
} from './dto/customer-app.dto';
import { CustomerOnlyGuard } from './guards/customer-only.guard';

@ApiTags('Customer App')
@ApiBearerAuth('access-token')
@UseGuards(CustomerOnlyGuard)
@Controller('customer-app')
export class CustomerAppController {
  constructor(private readonly service: CustomerAppService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Customer home dashboard' })
  getDashboard(@CurrentCustomer() customer: AuthenticatedCustomer) {
    return this.service.getDashboard(customer.customerId);
  }

  @Get('orders')
  @ApiOperation({ summary: 'List customer orders' })
  getOrders(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Query() query: CustomerOrderQueryDto,
  ) {
    return this.service.getOrders(customer.customerId, query);
  }

  @Get('orders/:orderId')
  @ApiOperation({ summary: 'Get order detail' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  getOrder(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
  ) {
    return this.service.getOrderDetail(customer.customerId, orderId);
  }

  @Get('orders/:orderId/timeline')
  @ApiOperation({ summary: 'Get order timeline' })
  getTimeline(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
  ) {
    return this.service.getOrderTimeline(customer.customerId, orderId);
  }

  @Get('orders/:orderId/laundry-tracking')
  @ApiOperation({ summary: 'Get laundry progress tracking' })
  getLaundryTracking(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
  ) {
    return this.service.getLaundryTracking(customer.customerId, orderId);
  }

  @Get('orders/:orderId/delivery-tracking')
  @ApiOperation({ summary: 'Get delivery tracking' })
  getDeliveryTracking(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
  ) {
    return this.service.getDeliveryTracking(customer.customerId, orderId);
  }

  @Post('pickup-requests')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create pickup request' })
  createPickupRequest(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Body() dto: CustomerPickupRequestDto,
  ) {
    return this.service.createPickupRequest(customer.customerId, dto);
  }

  @Get('rewards')
  @ApiOperation({ summary: 'Get reward points summary' })
  getRewards(@CurrentCustomer() customer: AuthenticatedCustomer) {
    return this.service.getRewards(customer.customerId);
  }

  @Get('rewards/history')
  @ApiOperation({ summary: 'Get reward points history' })
  getRewardHistory(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Query() query: CustomerRewardQueryDto,
  ) {
    return this.service.getRewardHistory(customer.customerId, query);
  }
}
