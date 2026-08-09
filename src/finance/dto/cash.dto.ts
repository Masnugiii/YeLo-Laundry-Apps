import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class OpenShiftDto {
  @ApiProperty({ example: 500000, description: 'Opening cash float amount' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  openingCash!: number;

  @ApiPropertyOptional({ example: 'Morning shift opening' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class CloseShiftDto {
  @ApiProperty({ example: 1250000, description: 'Actual cash counted in drawer' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  actualCash!: number;

  @ApiPropertyOptional({ example: 'End of day closing' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export enum CashTransactionType {
  CASH_IN = 'CASH_IN',
  CASH_OUT = 'CASH_OUT',
}

export class CashTransactionDto {
  @ApiProperty({ enum: CashTransactionType, example: CashTransactionType.CASH_IN })
  @IsEnum(CashTransactionType)
  type!: CashTransactionType;

  @ApiProperty({ example: 100000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiPropertyOptional({ example: 'Petty cash top-up' })
  @IsOptional()
  @IsString()
  description?: string;
}

export class DailyClosingQueryDto {
  @ApiPropertyOptional({ example: '20260808' })
  @IsOptional()
  @IsString()
  date?: string;
}

export class AdjustIncomeDto {
  @ApiProperty({ example: 50000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiProperty({ example: 'Manual income adjustment for unrecorded sale' })
  @IsString()
  description!: string;
}

export class ValidateVoucherDto {
  @ApiProperty({ example: 'WELCOME10' })
  @IsString()
  code!: string;

  @ApiPropertyOptional({ example: 28000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  orderAmount?: number;
}

export class CreateVoucherDto {
  @ApiProperty({ example: 'WELCOME10' })
  @IsString()
  code!: string;

  @ApiProperty({ example: 'PERCENTAGE', enum: ['PERCENTAGE', 'FIXED'] })
  @IsEnum(['PERCENTAGE', 'FIXED'])
  type!: 'PERCENTAGE' | 'FIXED';

  @ApiProperty({ example: 10 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  value!: number;

  @ApiProperty({ example: '2026-12-31' })
  @Type(() => Date)
  @IsDate()
  expiresAt!: Date;

  @ApiProperty({ example: 100 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  maxUsage!: number;
}
