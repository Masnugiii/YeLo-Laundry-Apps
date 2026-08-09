import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
} from 'class-validator';

export class DeductWalletDto {
  @ApiProperty({ example: 25000, description: 'Deduction amount in IDR' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount!: number;

  @ApiPropertyOptional({ example: 'Laundry Payment' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  notes?: string;
}
