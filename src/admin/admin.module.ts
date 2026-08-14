import { Module, forwardRef } from '@nestjs/common';
import { DashboardModule } from '../dashboard/dashboard.module';
import { FinanceModule } from '../finance/finance.module';
import { PlatformModule } from '../platform/platform.module';
import { SettingsModule } from '../settings/settings.module';
import { AdminController } from './admin.controller';
import { AdminDashboardService } from './admin-dashboard.service';

@Module({
  imports: [
    DashboardModule,
    PlatformModule,
    forwardRef(() => FinanceModule),
    forwardRef(() => SettingsModule),
  ],
  controllers: [AdminController],
  providers: [AdminDashboardService],
  exports: [AdminDashboardService, PlatformModule],
})
export class AdminModule {}
