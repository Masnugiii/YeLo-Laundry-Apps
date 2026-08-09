import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  Max,
  Min,
} from 'class-validator';

export enum WalletTransactionTypeFilter {
  TOPUP = 'TOPUP',
  PAYMENT = 'PAYMENT',
  REFUND = 'REFUND',
  ADJUSTMENT = 'ADJUSTMENT',
  CASHBACK = 'CASHBACK',
  PROMOTION = 'PROMOTION',
  MANUAL_CREDIT = 'MANUAL_CREDIT',
  MANUAL_DEBIT = 'MANUAL_DEBIT',
}

export class WalletTransactionQueryDto {
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
    enum: WalletTransactionTypeFilter,
    example: WalletTransactionTypeFilter.TOPUP,
  })
  @IsOptional()
  @IsEnum(WalletTransactionTypeFilter)
  type?: WalletTransactionTypeFilter;

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
