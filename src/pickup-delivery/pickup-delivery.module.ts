import { Module } from '@nestjs/common';
import { NotificationModule } from '../notification/notification.module';
import { DeliveryController } from './delivery.controller';
import { DriverController } from './driver.controller';
import { OrderPickupDeliveryController } from './order-pickup-delivery.controller';
import { PickupController } from './pickup.controller';
import { PickupDeliveryAuditService } from './pickup-delivery-audit.service';
import { PickupDeliveryController } from './pickup-delivery.controller';
import { PickupDeliveryRepository } from './pickup-delivery.repository';
import { PickupDeliveryService } from './pickup-delivery.service';
import { TrackingController } from './tracking.controller';

@Module({
  imports: [NotificationModule],
  controllers: [
    PickupDeliveryController,
    PickupController,
    DeliveryController,
    DriverController,
    TrackingController,
    OrderPickupDeliveryController,
  ],
  providers: [
    PickupDeliveryService,
    PickupDeliveryRepository,
    PickupDeliveryAuditService,
  ],
  exports: [PickupDeliveryService, PickupDeliveryRepository],
})
export class PickupDeliveryModule {}
