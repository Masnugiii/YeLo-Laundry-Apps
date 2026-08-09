import { Module } from '@nestjs/common';
import { DashboardModule } from '../dashboard/dashboard.module';
import { FinanceModule } from '../finance/finance.module';
import { AdminController } from './admin.controller';
import { AdminDashboardService } from './admin-dashboard.service';
import { AdminSettingsService } from './admin-settings.service';
import { AuditLogService } from './audit-log.service';

@Module({
  imports: [DashboardModule, FinanceModule],
  controllers: [AdminController],
  providers: [AdminDashboardService, AdminSettingsService, AuditLogService],
  exports: [AdminDashboardService, AuditLogService, AdminSettingsService],
})
export class AdminModule {}
