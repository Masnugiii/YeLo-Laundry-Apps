import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { OtpPurpose } from '@prisma/client';
import { IsEnum, IsNotEmpty, IsOptional, Matches } from 'class-validator';

const PHONE_PATTERN = /^(\+62|62|0)8[1-9][0-9]{6,11}$/;

export class DevGenerateOtpDto {
  @ApiProperty({ example: '081234567890' })
  @IsNotEmpty()
  @Matches(PHONE_PATTERN, { message: 'Invalid Indonesian mobile number' })
  phone!: string;

  @ApiPropertyOptional({ enum: OtpPurpose, example: OtpPurpose.login })
  @IsOptional()
  @IsEnum(OtpPurpose)
  purpose: OtpPurpose = OtpPurpose.login;
}

export class DevGenerateOtpResponseDto {
  @ApiProperty({ example: '081234567890' })
  phone!: string;

  @ApiProperty({ example: '482731' })
  otp!: string;

  @ApiProperty({ example: 300 })
  expiresIn!: number;
}
