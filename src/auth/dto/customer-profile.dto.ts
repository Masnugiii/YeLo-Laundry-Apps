import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDate, IsOptional, IsString } from 'class-validator';

export class CustomerProfileResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  customerCode!: string;

  @ApiProperty()
  fullName!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional()
  email?: string | null;

  @ApiPropertyOptional()
  gender?: string | null;

  @ApiPropertyOptional()
  birthDate?: string | null;

  @ApiPropertyOptional()
  photoUrl?: string | null;

  @ApiPropertyOptional()
  occupation?: string | null;

  @ApiProperty()
  loyaltyPoints!: number;

  @ApiProperty()
  walletBalance!: number;
}

export class UpdateCustomerProfileDto {
  @ApiPropertyOptional()
  fullName?: string;

  @ApiPropertyOptional()
  email?: string;

  @ApiPropertyOptional({ example: '1998-08-09' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  birthDate?: Date;

  @ApiPropertyOptional()
  photoUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  occupation?: string;
}
