import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export enum WalletAdjustDirection {
  INCREASE = 'increase',
  DECREASE = 'decrease',
}

export class AdjustWalletDto {
  @ApiProperty({ example: 50000, description: 'Adjustment amount in IDR' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount!: number;

  @ApiProperty({
    enum: WalletAdjustDirection,
    example: WalletAdjustDirection.INCREASE,
    description: 'Increase or decrease wallet balance',
  })
  @IsEnum(WalletAdjustDirection)
  direction!: WalletAdjustDirection;

  @ApiPropertyOptional({ example: 'Manual balance correction' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  notes?: string;
}
