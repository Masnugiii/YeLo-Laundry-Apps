import { Module } from '@nestjs/common';
import { LaundryAuditService } from './laundry-audit.service';
import { LaundryController } from './laundry.controller';
import { LaundryRepository } from './laundry.repository';
import { LaundryService } from './laundry.service';
import { ProductionHistoryService } from './production-history.service';
import { ProductionSettingsRepository } from './production-settings.repository';
import { QualityControlService } from './quality-control.service';

@Module({
  controllers: [LaundryController],
  providers: [
    LaundryService,
    LaundryRepository,
    ProductionHistoryService,
    ProductionSettingsRepository,
    QualityControlService,
    LaundryAuditService,
  ],
  exports: [LaundryService, LaundryRepository, ProductionSettingsRepository],
})
export class LaundryModule {}
