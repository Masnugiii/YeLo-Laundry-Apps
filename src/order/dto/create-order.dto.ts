import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { OrderPaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsDate,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export class CreateOrderItemDto {
  @ApiProperty({ example: 'dd0e8400-e29b-41d4-a716-446655440009' })
  @IsUUID()
  serviceId!: string;

  @ApiProperty({ example: 3.5, description: 'Quantity or weight depending on service unit' })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @IsPositive()
  quantity!: number;

  @ApiPropertyOptional({ example: 3.5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @IsPositive()
  weight?: number;

  @ApiPropertyOptional({ example: 'Jangan pakai pewangi' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}

export class CreateOrderDto {
  @ApiProperty({ example: '990e8400-e29b-41d4-a716-446655440005' })
  @IsUUID()
  customerId!: string;

  @ApiProperty({ example: '2026-08-10T17:00:00.000Z' })
  @Type(() => Date)
  @IsDate()
  estimatedFinishDate!: Date;

  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[];

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  discountAmount?: number;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  taxAmount?: number;

  @ApiPropertyOptional({ example: 0, default: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  serviceFeeAmount?: number;

  @ApiPropertyOptional({ example: false, default: false })
  @IsOptional()
  @IsBoolean()
  pickupRequired?: boolean;

  @ApiPropertyOptional({ example: false, default: false })
  @IsOptional()
  @IsBoolean()
  deliveryRequired?: boolean;

  @ApiPropertyOptional({ example: 'aa0e8400-e29b-41d4-a716-446655440006' })
  @IsOptional()
  @IsUUID()
  pickupAddressId?: string;

  @ApiPropertyOptional({ example: 'aa0e8400-e29b-41d4-a716-446655440006' })
  @IsOptional()
  @IsUUID()
  deliveryAddressId?: string;

  @ApiPropertyOptional({ enum: OrderPaymentMethod })
  @IsOptional()
  @IsEnum(OrderPaymentMethod)
  paymentMethod?: OrderPaymentMethod;

  @ApiPropertyOptional({ example: 'Pelanggan minta cepat' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({
    example: 'bb0e8400-e29b-41d4-a716-446655440010',
    description: 'Optional CKS reward entitlement (reward redemption item id)',
  })
  @IsOptional()
  @IsUUID()
  rewardRedemptionItemId?: string;
}
