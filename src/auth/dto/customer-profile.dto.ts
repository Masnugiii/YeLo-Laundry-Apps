import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

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

  @ApiPropertyOptional()
  photoUrl?: string;
}
