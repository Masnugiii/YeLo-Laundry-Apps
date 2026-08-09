import { Module } from '@nestjs/common';
import { CustomerAddressController } from './customer-address.controller';
import { CustomerAddressRepository } from './customer-address.repository';
import { CustomerAddressService } from './customer-address.service';
import { CustomerController } from './customer.controller';
import { CustomerDeviceController } from './customer-device.controller';
import { CustomerDeviceRepository } from './customer-device.repository';
import { CustomerDeviceService } from './customer-device.service';
import { CustomerSelfGuard } from './guards/customer-self.guard';
import { CustomerDeviceViewGuard } from './guards/customer-device-view.guard';
import { CustomerNoteController } from './customer-note.controller';
import { CustomerNoteRepository } from './customer-note.repository';
import { CustomerNoteService } from './customer-note.service';
import { CustomerWalletController } from './customer-wallet.controller';
import { CustomerWalletRepository } from './customer-wallet.repository';
import { CustomerWalletService } from './customer-wallet.service';
import { CustomerRepository } from './customer.repository';
import { CustomerService } from './customer.service';

@Module({
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
    CustomerWalletService,
    CustomerWalletRepository,
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
  ],
})
export class CustomerModule {}
