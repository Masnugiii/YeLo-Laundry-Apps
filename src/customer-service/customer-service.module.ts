import { Module } from '@nestjs/common';
import { CustomerServiceController } from './customer-service.controller';
import { CustomerServiceRepository } from './customer-service.repository';
import { CustomerServiceService } from './customer-service.service';

@Module({
  controllers: [CustomerServiceController],
  providers: [CustomerServiceService, CustomerServiceRepository],
  exports: [CustomerServiceService],
})
export class CustomerServiceModule {}
