import { Module, forwardRef } from '@nestjs/common';
import { NumberingModule } from '../numbering/numbering.module';
import { LoyaltyModule } from '../loyalty/loyalty.module';
import { SettingsConfigModule } from '../settings/settings-config.module';
import { CustomerAddressController } from './customer-address.controller';
import { CustomerAddressRepository } from './customer-address.repository';
import { CustomerAddressService } from './customer-address.service';
import { CustomerController } from './customer.controller';
import { CustomerDeviceController } from './customer-device.controller';
import { CustomerDeviceRepository } from './customer-device.repository';
import { CustomerDeviceService } from './customer-device.service';
import { CustomerSelfGuard } from './guards/customer-self.guard';
import { CustomerDeviceViewGuard } from './guards/customer-device-view.guard';
import { CustomerWalletViewGuard } from './guards/customer-wallet-view.guard';
import { CustomerNoteController } from './customer-note.controller';
import { CustomerNoteRepository } from './customer-note.repository';
import { CustomerNoteService } from './customer-note.service';
import { CustomerWalletController } from './customer-wallet.controller';
import { CustomerWalletRepository } from './customer-wallet.repository';
import { CustomerWalletService } from './customer-wallet.service';
import { CustomerWalletTopUpService } from './customer-wallet-topup.service';
import { CustomerRepository } from './customer.repository';
import { CustomerService } from './customer.service';

@Module({
  imports: [
    NumberingModule,
    SettingsConfigModule,
    forwardRef(() => LoyaltyModule),
  ],
  controllers: [
    CustomerController,
    CustomerAddressController,
    CustomerNoteController,
    CustomerDeviceController,
    CustomerWalletController,
  ],
  providers: [
    CustomerService,
    CustomerRepository,
    CustomerAddressService,
    CustomerAddressRepository,
    CustomerNoteService,
    CustomerNoteRepository,
    CustomerDeviceService,
    CustomerDeviceRepository,
    CustomerSelfGuard,
    CustomerDeviceViewGuard,
    CustomerWalletViewGuard,
    CustomerWalletService,
    CustomerWalletRepository,
    CustomerWalletTopUpService,
  ],
  exports: [
    CustomerService,
    CustomerRepository,
    CustomerAddressService,
    CustomerAddressRepository,
    CustomerNoteService,
    CustomerNoteRepository,
    CustomerDeviceService,
    CustomerDeviceRepository,
    CustomerWalletService,
    CustomerWalletRepository,
    CustomerWalletTopUpService,
  ],
})
export class CustomerModule {}
