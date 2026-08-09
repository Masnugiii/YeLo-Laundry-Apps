import { ApiPropertyOptional } from '@nestjs/swagger';
import { OrderPaymentMethod, OrderStatus } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export class UpdateOrderDto {
  @ApiPropertyOptional({ example: '2026-08-10T17:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  estimatedFinishDate?: Date;

  @ApiPropertyOptional({ example: 5000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  discountAmount?: number;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  taxAmount?: number;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  serviceFeeAmount?: number;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  pickupRequired?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  deliveryRequired?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  pickupAddressId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  deliveryAddressId?: string;

  @ApiPropertyOptional({ enum: OrderPaymentMethod })
  @IsOptional()
  @IsEnum(OrderPaymentMethod)
  paymentMethod?: OrderPaymentMethod;

  @ApiPropertyOptional({ example: 'Updated internal note' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ enum: OrderStatus })
  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional({ example: 'Moving to ironing queue' })
  @IsOptional()
  @IsString()
  statusNotes?: string;
}
