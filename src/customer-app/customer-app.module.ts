import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { CustomerModule } from '../customer/customer.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { MasterDataModule } from '../master-data/master-data.module';
import { NotificationModule } from '../notification/notification.module';
import { OrderModule } from '../order/order.module';
import { PickupDeliveryModule } from '../pickup-delivery/pickup-delivery.module';
import { PlatformModule } from '../platform/platform.module';
import { SettingsConfigModule } from '../settings/settings-config.module';
import { CustomerServiceModule } from '../customer-service/customer-service.module';
import { FinanceModule } from '../finance/finance.module';
import { CustomerAppController } from './customer-app.controller';
import { CustomerAppService } from './customer-app.service';
import { CustomerOnlyGuard } from './guards/customer-only.guard';

@Module({
  imports: [
    AuthModule,
    PlatformModule,
    SettingsConfigModule,
    CustomerModule,
    LoyaltyModule,
    MasterDataModule,
    OrderModule,
    NotificationModule,
    PickupDeliveryModule,
    CustomerServiceModule,
    FinanceModule,
  ],
  controllers: [CustomerAppController],
  providers: [CustomerAppService, CustomerOnlyGuard],
})
export class CustomerAppModule {}
