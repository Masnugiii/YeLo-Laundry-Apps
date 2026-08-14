import { Module } from '@nestjs/common';
import { AttendanceModule } from '../attendance/attendance.module';
import { PlatformModule } from '../platform/platform.module';
import { AttendanceConfigService } from './config/attendance-config.service';
import { BackupSettingsService } from './config/backup-settings.service';
import { DocumentRulesService } from './config/document-rules.service';
import { NotificationConfigService } from './config/notification-config.service';
import { PaymentConfigService } from './config/payment-config.service';
import { ReceiptConfigService } from './config/receipt-config.service';

@Module({
  imports: [PlatformModule, AttendanceModule],
  providers: [
    PaymentConfigService,
    NotificationConfigService,
    DocumentRulesService,
    BackupSettingsService,
    AttendanceConfigService,
    ReceiptConfigService,
  ],
  exports: [
    PaymentConfigService,
    NotificationConfigService,
    DocumentRulesService,
    BackupSettingsService,
    AttendanceConfigService,
    ReceiptConfigService,
  ],
})
export class SettingsConfigModule {}
