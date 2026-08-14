import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID, Matches } from 'class-validator';

const PHONE_PATTERN = /^(\+62|62|0)8[1-9][0-9]{6,11}$/;

export class RequestChangePhoneDto {
  @ApiProperty({ example: '+6281234567891' })
  @IsNotEmpty()
  @Matches(PHONE_PATTERN, { message: 'Invalid Indonesian mobile number' })
  phone!: string;
}

export class VerifyChangePhoneDto {
  @ApiProperty({ example: '+6281234567891' })
  @IsNotEmpty()
  @Matches(PHONE_PATTERN, { message: 'Invalid Indonesian mobile number' })
  phone!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  otpRequestId!: string;

  @ApiProperty({ example: '123456' })
  @Matches(/^\d{6}$/, { message: 'OTP must be a 6-digit code' })
  otpCode!: string;
}
