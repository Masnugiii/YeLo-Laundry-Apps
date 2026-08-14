import { Module, forwardRef } from '@nestjs/common';
import { PlatformModule } from '../platform/platform.module';
import { PayrollModule } from '../payroll/payroll.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { NumberingModule } from '../numbering/numbering.module';
import { ConfigAuditService } from './audit/config-audit.service';
import { OwnerWriteGuard } from './guards/owner-write.guard';
import { SettingsConfigModule } from './settings-config.module';
import { SettingsController } from './settings.controller';
import { SettingsService } from './settings.service';

@Module({
  imports: [
    PlatformModule,
    SettingsConfigModule,
    forwardRef(() => PayrollModule),
    forwardRef(() => LoyaltyModule),
    NumberingModule,
  ],
  controllers: [SettingsController],
  providers: [SettingsService, ConfigAuditService, OwnerWriteGuard],
  exports: [
    SettingsService,
    ConfigAuditService,
    SettingsConfigModule,
    OwnerWriteGuard,
  ],
})
export class SettingsModule {}
