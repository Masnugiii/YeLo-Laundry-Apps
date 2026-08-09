import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, Length, Matches } from 'class-validator';

const PHONE_PATTERN = /^(\+62|62|0)8[1-9][0-9]{6,11}$/;

export class VerifyOtpDto {
  @ApiProperty({ example: '770e8400-e29b-41d4-a716-446655440002' })
  @IsUUID()
  otpRequestId!: string;

  @ApiProperty({ example: '081234567890' })
  @IsNotEmpty()
  @Matches(PHONE_PATTERN, { message: 'Invalid Indonesian mobile number' })
  phone!: string;

  @ApiProperty({ example: '482910' })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: 'OTP code must be exactly 6 digits' })
  otpCode!: string;

  @ApiPropertyOptional({ example: 'Customer App / iOS 17' })
  @IsOptional()
  @IsString()
  deviceInfo?: string;
}
