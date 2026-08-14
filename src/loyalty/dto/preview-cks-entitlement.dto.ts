import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

export class PreviewCksEntitlementDto {
  @ApiProperty({ example: 'aa0e8400-e29b-41d4-a716-446655440001' })
  @IsUUID()
  redemptionItemId!: string;

  @ApiProperty({ example: 7, description: 'Laundry order weight in KG' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @IsPositive()
  orderKg!: number;

  @ApiPropertyOptional({ example: 'CKS', default: 'CKS' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  serviceType?: string;
}
