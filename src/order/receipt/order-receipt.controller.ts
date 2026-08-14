import {
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
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../../auth/constants/roles.constant';
import { PERMISSIONS } from '../../auth/constants/permissions.constant';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Permissions } from '../../auth/decorators/permissions.decorator';
import { Roles } from '../../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../../auth/interfaces/jwt-payload.interface';
import { OrderReceiptService } from './order-receipt.service';

const RECEIPT_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
] as const;

@ApiTags('Order Receipts')
@ApiBearerAuth()
@Permissions(PERMISSIONS.ORDERS)
@Controller('orders/:orderId/receipts')
export class OrderReceiptController {
  constructor(private readonly orderReceiptService: OrderReceiptService) {}

  @Post('whatsapp/generate')
  @Roles(...RECEIPT_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Generate WhatsApp order receipt from current order state' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  generate(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.orderReceiptService.generateReceipt(orderId, user.employeeId);
  }

  @Post('whatsapp/:receiptId/send')
  @Roles(...RECEIPT_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send generated receipt via configured WhatsApp provider' })
  send(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Param('receiptId', ParseUUIDPipe) receiptId: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.orderReceiptService.sendViaWhatsapp(
      orderId,
      receiptId,
      user.employeeId,
    );
  }

  @Post('whatsapp/:receiptId/handoff')
  @Roles(...RECEIPT_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Record manual WhatsApp handoff for a generated receipt' })
  handoff(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Param('receiptId', ParseUUIDPipe) receiptId: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.orderReceiptService.recordManualHandoff(
      orderId,
      receiptId,
      user.employeeId,
    );
  }

  @Get()
  @Roles(...RECEIPT_ROLES)
  @ApiOperation({ summary: 'List WhatsApp receipt delivery attempts for an order' })
  list(@Param('orderId', ParseUUIDPipe) orderId: string) {
    return this.orderReceiptService.listDeliveries(orderId);
  }
}
