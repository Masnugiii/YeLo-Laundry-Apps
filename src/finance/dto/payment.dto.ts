import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PaymentStatus } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export enum ApiPaymentMethod {
  CASH = 'CASH',
  QRIS = 'QRIS',
  BANK_TRANSFER = 'BANK_TRANSFER',
  DEBIT_CARD = 'DEBIT_CARD',
  CREDIT_CARD = 'CREDIT_CARD',
  EWALLET = 'EWALLET',
  CUSTOMER_WALLET = 'CUSTOMER_WALLET',
}

export enum DiscountType {
  PERCENTAGE = 'PERCENTAGE',
  FIXED = 'FIXED',
  MANUAL = 'MANUAL',
  VOUCHER = 'VOUCHER',
}

export class PaymentQueryDto {
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
    example: 'PAY-20260808-000001',
    description: 'Search by reference, invoice, order number, customer name or phone',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: '990e8400-e29b-41d4-a716-446655440005' })
  @IsOptional()
  @IsUUID()
  customerId?: string;

  @ApiPropertyOptional({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsOptional()
  @IsUUID()
  orderId?: string;

  @ApiPropertyOptional({ enum: ApiPaymentMethod })
  @IsOptional()
  @IsEnum(ApiPaymentMethod)
  paymentMethod?: ApiPaymentMethod;

  @ApiPropertyOptional({ enum: PaymentStatus })
  @IsOptional()
  @IsEnum(PaymentStatus)
  paymentStatus?: PaymentStatus;

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

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;
}

export class CreatePaymentDto {
  @ApiProperty({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsUUID()
  orderId!: string;

  @ApiProperty({ enum: ApiPaymentMethod, example: ApiPaymentMethod.CASH })
  @IsEnum(ApiPaymentMethod)
  paymentMethod!: ApiPaymentMethod;

  @ApiProperty({ example: 28000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiPropertyOptional({ enum: PaymentStatus, default: PaymentStatus.PAID })
  @IsOptional()
  @IsEnum(PaymentStatus)
  paymentStatus?: PaymentStatus = PaymentStatus.PAID;

  @ApiPropertyOptional({ example: 'Payment at counter' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ enum: DiscountType })
  @IsOptional()
  @IsEnum(DiscountType)
  discountType?: DiscountType;

  @ApiPropertyOptional({ example: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  discountValue?: number;

  @ApiPropertyOptional({ example: 'WELCOME10' })
  @IsOptional()
  @IsString()
  voucherCode?: string;
}

export class UpdatePaymentDto {
  @ApiPropertyOptional({ enum: PaymentStatus })
  @IsOptional()
  @IsEnum(PaymentStatus)
  paymentStatus?: PaymentStatus;

  @ApiPropertyOptional({ example: 28000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount?: number;

  @ApiPropertyOptional({ example: 'Updated payment notes' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class RefundPaymentDto {
  @ApiProperty({ example: 28000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiProperty({ example: 'Customer requested refund due to damaged item' })
  @IsString()
  reason!: string;
}
