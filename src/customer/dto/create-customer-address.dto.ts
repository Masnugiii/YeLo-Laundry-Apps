import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class CreateCustomerAddressDto {
  @ApiPropertyOptional({
    example: 'Rumah',
    description:
      'Address label for display (e.g. Rumah, Kantor). Accepted in request; persistence requires a future schema field.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  label?: string;

  @ApiProperty({ example: 'Nugroho Prasetyo' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  recipientName!: string;

  @ApiProperty({ example: '081234567890' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  phone!: string;

  @ApiProperty({ example: 'Jl. Melati No.1' })
  @IsString()
  @IsNotEmpty()
  address!: string;

  @ApiProperty({ example: 'Jawa Timur' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  province!: string;

  @ApiProperty({ example: 'Probolinggo' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  city!: string;

  @ApiProperty({ example: 'Mayangan' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  district!: string;

  @ApiPropertyOptional({ example: '67217' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  postalCode?: string;

  @ApiPropertyOptional({ example: -7.756 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @ApiPropertyOptional({ example: 113.215 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;

  @ApiPropertyOptional({ example: true, default: false })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @ApiPropertyOptional({
    example: 'Pagar hitam',
    description:
      'Delivery notes for couriers. Accepted in request; persistence requires a future schema field.',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
