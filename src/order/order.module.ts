import { Module } from '@nestjs/common';
import { CustomerModule } from '../customer/customer.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { NotificationModule } from '../notification/notification.module';
import { OrderController } from './order.controller';
import { OrderRepository } from './order.repository';
import { OrderService } from './order.service';

@Module({
  imports: [CustomerModule, NotificationModule, LoyaltyModule],
  controllers: [OrderController],
  providers: [OrderService, OrderRepository],
  exports: [OrderService, OrderRepository],
})
export class OrderModule {}
