import { Module, forwardRef } from '@nestjs/common';
import { PlatformModule } from '../platform/platform.module';
import { CustomerModule } from '../customer/customer.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { NotificationModule } from '../notification/notification.module';
import { NumberingModule } from '../numbering/numbering.module';
import { StorageModule } from '../storage/storage.module';
import { OrderAuditService } from './order-audit.service';
import { OrderController } from './order.controller';
import { OrderRepository } from './order.repository';
import { OrderService } from './order.service';
import { OrderStatusTransitionService } from './order-status-transition.service';
import { OrderReceiptController } from './receipt/order-receipt.controller';
import { OrderReceiptRepository } from './receipt/order-receipt.repository';
import { OrderReceiptService } from './receipt/order-receipt.service';
import { UnconfiguredWhatsappProvider } from './receipt/unconfigured-whatsapp.provider';

@Module({
  imports: [
    PlatformModule,
    forwardRef(() => CustomerModule),
    NotificationModule,
    forwardRef(() => LoyaltyModule),
    NumberingModule,
    forwardRef(() => StorageModule),
  ],
  controllers: [OrderController, OrderReceiptController],
  providers: [
    OrderService,
    OrderRepository,
    OrderStatusTransitionService,
    OrderAuditService,
    OrderReceiptService,
    OrderReceiptRepository,
    UnconfiguredWhatsappProvider,
  ],
  exports: [
    OrderService,
    OrderRepository,
    OrderStatusTransitionService,
    OrderAuditService,
  ],
})
export class OrderModule {}
