import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class TopupWalletDto {
  @ApiProperty({ example: 100000, description: 'Top-up amount in IDR' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount!: number;

  @ApiPropertyOptional({ example: 'Top Up by Cash' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  notes?: string;
}
