import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { CustomerModule } from '../customer/customer.module';
import { NotificationModule } from '../notification/notification.module';
import { OrderModule } from '../order/order.module';
import { PickupDeliveryModule } from '../pickup-delivery/pickup-delivery.module';
import { CustomerAppController } from './customer-app.controller';
import { CustomerAppService } from './customer-app.service';
import { CustomerOnlyGuard } from './guards/customer-only.guard';

@Module({
  imports: [
    AuthModule,
    CustomerModule,
    OrderModule,
    NotificationModule,
    PickupDeliveryModule,
  ],
  controllers: [CustomerAppController],
  providers: [CustomerAppService, CustomerOnlyGuard],
})
export class CustomerAppModule {}
