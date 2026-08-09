import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class UpdateCustomerAddressDto {
  @ApiPropertyOptional({ example: 'Rumah' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  label?: string;

  @ApiPropertyOptional({ example: 'Nugroho Prasetyo' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  recipientName?: string;

  @ApiPropertyOptional({ example: '081234567890' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({ example: 'Jl. Melati No.1' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  address?: string;

  @ApiPropertyOptional({ example: 'Jawa Timur' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  province?: string;

  @ApiPropertyOptional({ example: 'Probolinggo' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  city?: string;

  @ApiPropertyOptional({ example: 'Mayangan' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  district?: string;

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

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @ApiPropertyOptional({ example: 'Pagar hitam' })
  @IsOptional()
  @IsString()
  notes?: string;
}
