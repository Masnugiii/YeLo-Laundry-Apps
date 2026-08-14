import { Module } from '@nestjs/common';
import { AdminSettingsService } from '../admin/admin-settings.service';
import { AuditLogService } from '../admin/audit-log.service';
import { TaxService } from '../common/services/tax.service';

@Module({
  providers: [AdminSettingsService, AuditLogService, TaxService],
  exports: [AdminSettingsService, AuditLogService, TaxService],
})
export class PlatformModule {}
