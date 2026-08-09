import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class InvoiceQueryDto {
  @ApiPropertyOptional({ example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({
    example: 'INV-20260808',
    description: 'Search by invoice number, order number, or customer',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: '2026-08-01' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateFrom?: Date;

  @ApiPropertyOptional({ example: '2026-08-31' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateTo?: Date;
}

export class GenerateInvoiceDto {
  @ApiProperty({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsUUID()
  orderId!: string;
}

export class SendInvoiceDto {
  @ApiProperty({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional({ example: 'andi@email.com' })
  @IsOptional()
  @IsEmail()
  email?: string;
}
