import { Module } from '@nestjs/common';
import { CustomerModule } from '../customer/customer.module';
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
import { VoucherService } from './voucher.service';
import { CustomerLoyaltyService } from './customer-loyalty.service';
import { WalletLoyaltyService } from './wallet-loyalty.service';

@Module({
  imports: [CustomerModule],
  controllers: [
    WalletController,
    RewardController,
    MembershipController,
    VoucherController,
    LoyaltySettingsController,
    CustomerLoyaltyController,
  ],
  providers: [
    LoyaltySettingsService,
    MembershipService,
    RewardService,
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
    LoyaltyProcessorService,
    WalletLoyaltyService,
    CustomerLoyaltyService,
  ],
})
export class LoyaltyModule {}
