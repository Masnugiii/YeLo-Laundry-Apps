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
  CustomerCreateOrderDto,
  CustomerOrderQueryDto,
  CustomerPayOrderDto,
  CustomerPickupRequestDto,
  CustomerPromoQueryDto,
  CustomerPromoQuoteDto,
  CustomerRedeemRewardsDto,
  CustomerRewardQueryDto,
  CustomerWalletTopUpDto,
  CreateSupportTicketDto,
  SendSupportMessageDto,
  CreateOrderFeedbackMessageDto,
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

  @Post('orders')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create customer laundry order' })
  createOrder(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Body() dto: CustomerCreateOrderDto,
  ) {
    return this.service.createOrder(customer.customerId, dto);
  }

  @Post('orders/:orderId/pay')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Pay customer order' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  payOrder(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: CustomerPayOrderDto,
  ) {
    return this.service.payOrder(customer.customerId, orderId, dto);
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

  @Get('orders/:orderId/feedback')
  @ApiOperation({ summary: 'Get order complaint / feedback messages' })
  getOrderFeedback(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
  ) {
    return this.service.getOrderFeedback(customer.customerId, orderId);
  }

  @Post('orders/:orderId/feedback')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Send order complaint / feedback message' })
  sendOrderFeedback(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: CreateOrderFeedbackMessageDto,
  ) {
    return this.service.sendOrderFeedback(
      customer.customerId,
      orderId,
      dto.message,
    );
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

  @Get('services')
  @ApiOperation({ summary: 'List active laundry services and prices' })
  getServices(@CurrentCustomer() _customer: AuthenticatedCustomer) {
    return this.service.getServices();
  }

  @Get('perfumes')
  @ApiOperation({ summary: 'List available perfume options' })
  getPerfumes(@CurrentCustomer() _customer: AuthenticatedCustomer) {
    return this.service.getPerfumes();
  }

  @Get('payment-config')
  @ApiOperation({ summary: 'Get customer payment configuration' })
  getPaymentConfig(@CurrentCustomer() _customer: AuthenticatedCustomer) {
    return this.service.getPaymentConfig();
  }

  @Get('promos')
  @ApiOperation({ summary: 'List active customer promos' })
  getPromos(
    @CurrentCustomer() _customer: AuthenticatedCustomer,
    @Query() query: CustomerPromoQueryDto,
  ) {
    return this.service.getPromos(query);
  }

  @Get('promos/:promoId')
  @ApiOperation({ summary: 'Get promo detail' })
  @ApiParam({ name: 'promoId', description: 'Promo UUID' })
  getPromo(
    @CurrentCustomer() _customer: AuthenticatedCustomer,
    @Param('promoId', ParseUUIDPipe) promoId: string,
  ) {
    return this.service.getPromoDetail(promoId);
  }

  @Post('promos/quote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Calculate promo discount from backend' })
  quotePromo(
    @CurrentCustomer() _customer: AuthenticatedCustomer,
    @Body() dto: CustomerPromoQuoteDto,
  ) {
    return this.service.quotePromo(dto);
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

  @Get('rewards/catalog')
  @ApiOperation({ summary: 'List active YeLo Rewards catalog' })
  getRewardCatalog(@CurrentCustomer() _customer: AuthenticatedCustomer) {
    return this.service.getRewardCatalog();
  }

  @Get('rewards/catalog/:catalogItemId')
  @ApiOperation({ summary: 'Get YeLo Rewards catalog item detail' })
  @ApiParam({ name: 'catalogItemId', description: 'Catalog item UUID' })
  getRewardCatalogItem(
    @CurrentCustomer() _customer: AuthenticatedCustomer,
    @Param('catalogItemId', ParseUUIDPipe) catalogItemId: string,
  ) {
    return this.service.getRewardCatalogItem(catalogItemId);
  }

  @Post('rewards/redeem')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Redeem YeLo Rewards catalog items' })
  redeemRewards(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Body() dto: CustomerRedeemRewardsDto,
  ) {
    return this.service.redeemRewards(customer.customerId, dto);
  }

  @Get('rewards/redemptions')
  @ApiOperation({ summary: 'List customer reward redemptions' })
  getRewardRedemptions(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Query() query: CustomerRewardQueryDto,
  ) {
    return this.service.getRewardRedemptions(customer.customerId, query);
  }

  @Get('rewards/redemptions/:redemptionId')
  @ApiOperation({ summary: 'Get customer reward redemption detail' })
  @ApiParam({ name: 'redemptionId', description: 'Redemption UUID' })
  getRewardRedemption(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('redemptionId', ParseUUIDPipe) redemptionId: string,
  ) {
    return this.service.getRewardRedemption(customer.customerId, redemptionId);
  }

  @Get('rewards/history')
  @ApiOperation({ summary: 'Get reward points history' })
  getRewardHistory(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Query() query: CustomerRewardQueryDto,
  ) {
    return this.service.getRewardHistory(customer.customerId, query);
  }

  @Post('wallet/top-up')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Initiate customer wallet top-up' })
  initiateWalletTopUp(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Body() dto: CustomerWalletTopUpDto,
  ) {
    return this.service.initiateWalletTopUp(customer.customerId, dto);
  }

  @Post('wallet/top-up/:requestId/confirm')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Confirm customer wallet top-up payment' })
  @ApiParam({ name: 'requestId', description: 'Top-up request UUID' })
  confirmWalletTopUp(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ) {
    return this.service.confirmWalletTopUp(customer.customerId, requestId);
  }

  @Get('wallet/top-up/:requestId/status')
  @ApiOperation({ summary: 'Get wallet top-up request status' })
  @ApiParam({ name: 'requestId', description: 'Top-up request UUID' })
  getWalletTopUpStatus(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('requestId', ParseUUIDPipe) requestId: string,
  ) {
    return this.service.getWalletTopUpStatus(customer.customerId, requestId);
  }

  @Get('missions')
  @ApiOperation({ summary: 'List loyalty missions for customer' })
  getMissions(@CurrentCustomer() customer: AuthenticatedCustomer) {
    return this.service.getMissions(customer.customerId);
  }

  @Post('missions/:missionId/claim')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Claim loyalty mission reward' })
  @ApiParam({ name: 'missionId', description: 'Mission UUID' })
  claimMission(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('missionId', ParseUUIDPipe) missionId: string,
  ) {
    return this.service.claimMission(customer.customerId, missionId);
  }

  @Get('support/tickets')
  @ApiOperation({ summary: 'List customer support tickets' })
  listSupportTickets(@CurrentCustomer() customer: AuthenticatedCustomer) {
    return this.service.listSupportTickets(customer.customerId);
  }

  @Post('support/tickets')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create customer support ticket' })
  createSupportTicket(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Body() dto: CreateSupportTicketDto,
  ) {
    return this.service.createSupportTicket(customer.customerId, dto);
  }

  @Get('support/tickets/:ticketId')
  @ApiOperation({ summary: 'Get customer support ticket detail' })
  @ApiParam({ name: 'ticketId', description: 'Ticket UUID' })
  getSupportTicket(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('ticketId', ParseUUIDPipe) ticketId: string,
  ) {
    return this.service.getSupportTicket(customer.customerId, ticketId);
  }

  @Post('support/tickets/:ticketId/messages')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Send message to support ticket' })
  @ApiParam({ name: 'ticketId', description: 'Ticket UUID' })
  sendSupportMessage(
    @CurrentCustomer() customer: AuthenticatedCustomer,
    @Param('ticketId', ParseUUIDPipe) ticketId: string,
    @Body() dto: SendSupportMessageDto,
  ) {
    return this.service.sendSupportMessage(
      customer.customerId,
      ticketId,
      dto,
    );
  }
}
