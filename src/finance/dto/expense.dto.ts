import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class ExpenseQueryDto {
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

  @ApiPropertyOptional({ example: 'electricity' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 'ELECTRICITY' })
  @IsOptional()
  @IsString()
  categoryCode?: string;

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
}

export class CreateExpenseDto {
  @ApiProperty({ example: 'ELECTRICITY' })
  @IsString()
  categoryCode!: string;

  @ApiProperty({ example: 'Electricity bill August' })
  @IsString()
  title!: string;

  @ApiPropertyOptional({ example: 'PLN monthly payment' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 350000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiProperty({ example: '2026-08-08' })
  @Type(() => Date)
  @IsDate()
  expenseDate!: Date;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/receipt.jpg' })
  @IsOptional()
  @IsString()
  receiptPhotoUrl?: string;
}

export class UpdateExpenseDto {
  @ApiPropertyOptional({ example: 'ELECTRICITY' })
  @IsOptional()
  @IsString()
  categoryCode?: string;

  @ApiPropertyOptional({ example: 'Electricity bill August' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ example: 'Updated description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 350000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount?: number;

  @ApiPropertyOptional({ example: '2026-08-08' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  expenseDate?: Date;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/receipt.jpg' })
  @IsOptional()
  @IsString()
  receiptPhotoUrl?: string;

  @ApiPropertyOptional({
    example: 'APPROVED',
    description: 'Manager approval action: APPROVED or REJECTED',
  })
  @IsOptional()
  @IsString()
  approvalAction?: 'APPROVED' | 'REJECTED';

  @ApiPropertyOptional({ example: 'Amount exceeds policy' })
  @IsOptional()
  @IsString()
  rejectionReason?: string;
}
