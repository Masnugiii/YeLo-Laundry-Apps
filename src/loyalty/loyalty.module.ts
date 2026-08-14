import { Module, forwardRef } from '@nestjs/common';
import { CustomerModule } from '../customer/customer.module';
import { MasterDataModule } from '../master-data/master-data.module';
import { SettingsModule } from '../settings/settings.module';
import { LoyaltyProcessorService } from './loyalty-processor.service';
import { LoyaltyReportService } from './loyalty-report.service';
import { LoyaltySettingsService } from './loyalty-settings.service';
import {
  LoyaltySettingsController,
  MembershipController,
  RewardController,
  VoucherController,
  WalletController,
  CustomerLoyaltyController,
} from './wallet.controller';
import { MembershipService } from './membership.service';
import { RewardService } from './reward.service';
import { MissionService } from './mission.service';
import { VoucherService } from './voucher.service';
import { CustomerLoyaltyService } from './customer-loyalty.service';
import { WalletLoyaltyService } from './wallet-loyalty.service';
import { RewardRedeemService } from './reward-redeem.service';
import { RewardEntitlementService } from './reward-entitlement.service';
import { RewardCatalogAdminService } from './reward-catalog-admin.service';
import { RewardCatalogController } from './reward-catalog.controller';

@Module({
  imports: [
    forwardRef(() => CustomerModule),
    forwardRef(() => SettingsModule),
    MasterDataModule,
  ],
  controllers: [
    WalletController,
    RewardController,
    MembershipController,
    VoucherController,
    LoyaltySettingsController,
    CustomerLoyaltyController,
    RewardCatalogController,
  ],
  providers: [
    LoyaltySettingsService,
    MembershipService,
    RewardService,
    RewardRedeemService,
    RewardEntitlementService,
    RewardCatalogAdminService,
    MissionService,
    VoucherService,
    WalletLoyaltyService,
    LoyaltyProcessorService,
    LoyaltyReportService,
    CustomerLoyaltyService,
  ],
  exports: [
    LoyaltySettingsService,
    MembershipService,
    RewardService,
    RewardRedeemService,
    RewardEntitlementService,
    MissionService,
    VoucherService,
    LoyaltyProcessorService,
    WalletLoyaltyService,
    CustomerLoyaltyService,
  ],
})
export class LoyaltyModule {}
