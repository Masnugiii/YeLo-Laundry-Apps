import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { CustomerModule } from '../customer/customer.module';
import { DevOtpController } from './dev-otp.controller';
import { DevOtpService } from './dev-otp.service';

@Module({
  imports: [AuthModule, CustomerModule],
  controllers: [DevOtpController],
  providers: [DevOtpService],
})
export class DevModule {}
