import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Gender } from '@prisma/client';
import {
  IsEmail,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Matches,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

const PHONE_PATTERN = /^(\+62|62|0)8[1-9][0-9]{6,11}$/;

export class CustomerRegisterDto {
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
  @Matches(/^\d{6}$/)
  otpCode!: string;

  @ApiProperty({ example: 'Nugroho Prasetyo' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(150)
  fullName!: string;

  @ApiPropertyOptional({ example: 'nugroho@example.com' })
  @IsOptional()
  @IsEmail()
  @MaxLength(150)
  email?: string;

  @ApiPropertyOptional({ enum: Gender })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiProperty({ example: 35 })
  @IsInt()
  @Min(13)
  @Max(100)
  age!: number;

  @ApiProperty({ example: 'Ibu Rumah Tangga' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  occupation!: string;
}
