import { ApiProperty } from '@nestjs/swagger';
import { OtpPurpose } from '@prisma/client';
import { IsEnum, IsNotEmpty, Matches } from 'class-validator';

const PHONE_PATTERN = /^(\+62|62|0)8[1-9][0-9]{6,11}$/;

export class SendOtpDto {
  @ApiProperty({ example: '081234567890' })
  @IsNotEmpty()
  @Matches(PHONE_PATTERN, { message: 'Invalid Indonesian mobile number' })
  phone!: string;

  @ApiProperty({ enum: OtpPurpose, example: OtpPurpose.login })
  @IsEnum(OtpPurpose)
  purpose!: OtpPurpose;
}
