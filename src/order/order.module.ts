import { Module } from '@nestjs/common';
import { CustomerModule } from '../customer/customer.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { NotificationModule } from '../notification/notification.module';
import { NumberingModule } from '../numbering/numbering.module';
import { OrderAuditService } from './order-audit.service';
import { OrderController } from './order.controller';
import { OrderRepository } from './order.repository';
import { OrderService } from './order.service';
import { OrderStatusTransitionService } from './order-status-transition.service';

@Module({
  imports: [CustomerModule, NotificationModule, LoyaltyModule, NumberingModule],
  controllers: [OrderController],
  providers: [
    OrderService,
    OrderRepository,
    OrderStatusTransitionService,
    OrderAuditService,
  ],
  exports: [
    OrderService,
    OrderRepository,
    OrderStatusTransitionService,
    OrderAuditService,
  ],
})
export class OrderModule {}
