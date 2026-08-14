import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { OrderPaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsDate,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class CustomerOrderQueryDto {
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

  @ApiPropertyOptional({ example: 'CREATED' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ example: 'YL-2026' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateFrom?: Date;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateTo?: Date;
}

export class CustomerPickupRequestDto {
  @ApiProperty({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional({ example: 'aa0e8400-e29b-41d4-a716-446655440006' })
  @IsOptional()
  @IsUUID()
  pickupAddressId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  scheduledPickupAt?: Date;

  @ApiPropertyOptional({ example: 'Pickup from home gate' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class CustomerRewardQueryDto {
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
}

export class CustomerRedeemRewardItemDto {
  @ApiProperty({ example: '11111111-1111-1111-1111-111111111111' })
  @IsUUID()
  catalogItemId!: string;

  @ApiProperty({ example: 1, minimum: 1 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  quantity!: number;
}

export class CustomerRedeemRewardsDto {
  @ApiProperty({ type: [CustomerRedeemRewardItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CustomerRedeemRewardItemDto)
  items!: CustomerRedeemRewardItemDto[];

  @ApiPropertyOptional({
    description:
      'Client-generated UUID for safe retries. Same key returns the same redemption.',
  })
  @IsOptional()
  @IsUUID()
  idempotencyKey?: string;
}

export class CustomerPromoQueryDto {
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
}

export class CustomerPromoQuoteDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  promoId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  voucherCode?: string;

  @ApiProperty({ example: 100000 })
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  subtotal!: number;
}

export class CreateOrderFeedbackMessageDto {
  @ApiProperty({ example: 'Parfum yang saya pilih kurang terasa.' })
  @IsString()
  @MinLength(1)
  @Max(2000)
  message!: string;
}

export class CustomerCreateOrderItemDto {
  @ApiProperty({ example: 'dd0e8400-e29b-41d4-a716-446655440009' })
  @IsUUID()
  serviceId!: string;

  @ApiProperty({ example: 2 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 3 })
  @IsPositive()
  quantity!: number;
}

export class CustomerCreateOrderDto {
  @ApiProperty({ type: [CustomerCreateOrderItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CustomerCreateOrderItemDto)
  items!: CustomerCreateOrderItemDto[];

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  pickupRequired?: boolean;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  deliveryRequired?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(4000)
  notes?: string;

  @ApiPropertyOptional({ enum: OrderPaymentMethod })
  @IsOptional()
  @IsEnum(OrderPaymentMethod)
  paymentMethod?: OrderPaymentMethod;

  @ApiPropertyOptional({ description: 'Selected perfume option ID' })
  @IsOptional()
  @IsUUID()
  perfumeId?: string;
}

export class CustomerWalletTopUpDto {
  @ApiProperty({ example: 50000 })
  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  amount!: number;

  @ApiProperty({ enum: ['QRIS', 'BANK_TRANSFER'] })
  @IsString()
  paymentMethod!: 'QRIS' | 'BANK_TRANSFER';
}

export class CreateSupportTicketDto {
  @ApiProperty({ example: 'PERTANYAAN' })
  @IsString()
  category!: string;

  @ApiProperty({ example: 'Pertanyaan tentang aplikasi' })
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  subject!: string;

  @ApiProperty({ example: 'Bagaimana cara melacak pesanan?' })
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  message!: string;
}

export class SendSupportMessageDto {
  @ApiProperty()
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  message!: string;
}

export class CustomerPayOrderDto {
  @ApiProperty({ example: 'YELO_WALLET' })
  @IsString()
  paymentMethod!: string;
}
