import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Min,
} from 'class-validator';
import { LoyaltyVoucherStatus } from '@prisma/client';

export class WalletQueryDto {
  @IsOptional() @IsUUID() customerId?: string;
}

export class WalletHistoryQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) page?: number = 1;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) limit?: number = 25;
  @IsOptional() @IsUUID() customerId?: string;
  @IsOptional() @IsString() type?: string;
  @IsOptional() @Type(() => Date) @IsDate() dateFrom?: Date;
  @IsOptional() @Type(() => Date) @IsDate() dateTo?: Date;
}

export class WalletTopupDto {
  @ApiProperty()
  @IsUUID()
  customerId!: string;

  @ApiProperty()
  @IsNumber()
  @Min(1)
  amount!: number;

  @IsOptional() @IsString() notes?: string;
}

export class WalletAdjustmentDto {
  @ApiProperty()
  @IsUUID()
  customerId!: string;

  @ApiProperty()
  @IsNumber()
  @Min(0.01)
  amount!: number;

  @ApiProperty({ enum: ['INCREASE', 'DECREASE'] })
  @IsEnum(['INCREASE', 'DECREASE'])
  direction!: 'INCREASE' | 'DECREASE';

  @IsOptional() @IsString() notes?: string;
}

export class WalletRefundDto {
  @ApiProperty()
  @IsUUID()
  customerId!: string;

  @ApiProperty()
  @IsNumber()
  @Min(0.01)
  amount!: number;

  @IsOptional() @IsString() notes?: string;
  @IsOptional() @IsUUID() referenceId?: string;
}

export class ReverseTransactionDto {
  @ApiProperty()
  @IsUUID()
  transactionId!: string;
}

export class RewardQueryDto {
  @IsOptional() @IsUUID() customerId?: string;
}

export class RewardHistoryQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) page?: number = 1;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) limit?: number = 25;
  @IsOptional() @IsUUID() customerId?: string;
  @IsOptional() @IsString() source?: string;
  @IsOptional() @Type(() => Date) @IsDate() dateFrom?: Date;
  @IsOptional() @Type(() => Date) @IsDate() dateTo?: Date;
}

export class ManualBonusDto {
  @ApiProperty()
  @IsUUID()
  customerId!: string;

  @ApiProperty()
  @IsInt()
  point!: number;

  @IsOptional() @IsString() description?: string;
}

export class CreateLoyaltyVoucherDto {
  @ApiProperty() @IsString() code!: string;
  @ApiProperty() @IsString() name!: string;
  @ApiProperty({ enum: ['PERCENTAGE', 'FIXED'] })
  @IsEnum(['PERCENTAGE', 'FIXED'])
  discountType!: 'PERCENTAGE' | 'FIXED';
  @ApiProperty() @IsNumber() @Min(0) discountValue!: number;
  @IsOptional() @IsEnum(['PERCENTAGE', 'FIXED']) cashbackType?: 'PERCENTAGE' | 'FIXED';
  @IsOptional() @IsNumber() cashbackValue?: number;
  @IsOptional() @IsNumber() cashbackMax?: number;
  @IsOptional() @IsInt() cashbackExpirationDays?: number;
  @ApiProperty() @Type(() => Date) @IsDate() startDate!: Date;
  @ApiProperty() @Type(() => Date) @IsDate() endDate!: Date;
  @IsOptional() @IsInt() usageLimit?: number;
  @IsOptional() @IsNumber() minimumTransaction?: number;
  @IsOptional() @IsEnum(LoyaltyVoucherStatus) status?: LoyaltyVoucherStatus;
}

export class VoucherQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) page?: number = 1;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) limit?: number = 25;
  @IsOptional() @IsEnum(LoyaltyVoucherStatus) status?: LoyaltyVoucherStatus;
  @IsOptional() @IsString() search?: string;
}

export class LoyaltyReportQueryDto {
  @IsOptional()
  @IsEnum(['wallet', 'reward', 'voucher', 'membership', 'top-customers'])
  reportType?: 'wallet' | 'reward' | 'voucher' | 'membership' | 'top-customers';
}

export class UpdateLoyaltySettingsDto {
  @IsOptional() @IsNumber() pointPerRupiah?: number;
  @IsOptional() @IsNumber() rupiahPerPoint?: number;
  @IsOptional() @IsInt() pointExpirationDays?: number;
  @IsOptional() membershipLevels?: Array<{
    code: string;
    name: string;
    minPoints: number;
    benefits: string[];
  }>;
  @IsOptional() cashback?: {
    enabled?: boolean;
    type?: 'PERCENTAGE' | 'FIXED';
    value?: number;
    maxAmount?: number;
    expirationDays?: number;
  };
  @IsOptional() wallet?: {
    minTopup?: number;
    allowManualDebit?: boolean;
  };
}
