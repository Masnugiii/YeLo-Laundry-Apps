import { Module, forwardRef } from '@nestjs/common';
import { AttendanceModule } from '../attendance/attendance.module';
import { AdminModule } from '../admin/admin.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { PayrollModule } from '../payroll/payroll.module';
import { AttendanceConfigService } from './config/attendance-config.service';
import { BackupSettingsService } from './config/backup-settings.service';
import { DocumentRulesService } from './config/document-rules.service';
import { NotificationConfigService } from './config/notification-config.service';
import { ConfigAuditService } from './audit/config-audit.service';
import { OwnerWriteGuard } from './guards/owner-write.guard';
import { SettingsController } from './settings.controller';
import { SettingsService } from './settings.service';

@Module({
  imports: [
    forwardRef(() => AdminModule),
    PayrollModule,
    LoyaltyModule,
    forwardRef(() => AttendanceModule),
  ],
  controllers: [SettingsController],
  providers: [
    SettingsService,
    ConfigAuditService,
    OwnerWriteGuard,
    DocumentRulesService,
    BackupSettingsService,
    AttendanceConfigService,
    NotificationConfigService,
  ],
  exports: [
    SettingsService,
    ConfigAuditService,
    NotificationConfigService,
    DocumentRulesService,
  ],
})
export class SettingsModule {}
