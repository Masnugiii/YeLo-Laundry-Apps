import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { PayrollModule } from '../payroll/payroll.module';
import { ConfigAuditService } from './audit/config-audit.service';
import { OwnerWriteGuard } from './guards/owner-write.guard';
import { SettingsController } from './settings.controller';
import { SettingsService } from './settings.service';

@Module({
  imports: [AdminModule, PayrollModule, LoyaltyModule],
  controllers: [SettingsController],
  providers: [SettingsService, ConfigAuditService, OwnerWriteGuard],
  exports: [SettingsService, ConfigAuditService],
})
export class SettingsModule {}
