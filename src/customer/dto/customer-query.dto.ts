import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export enum CustomerSortField {
  CREATED_AT = 'createdAt',
  UPDATED_AT = 'updatedAt',
  FULL_NAME = 'fullName',
  CUSTOMER_CODE = 'customerCode',
}

export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export class CustomerQueryDto {
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
    example: 'andi',
    description: 'Search by full name, phone, or customer code',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 'CUS-0042' })
  @IsOptional()
  @IsString()
  customerCode?: string;

  @ApiPropertyOptional({ example: 'Andi Wijaya' })
  @IsOptional()
  @IsString()
  fullName?: string;

  @ApiPropertyOptional({ example: '081122334455' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: 'andi@email.com' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({
    example: true,
    description: 'Filter by active status',
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return undefined;
  })
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({
    example: false,
    description: 'When true, return only soft-deleted customers',
  })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  deleted?: boolean;

  @ApiPropertyOptional({
    example: 'createdAt',
    enum: CustomerSortField,
    default: CustomerSortField.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(CustomerSortField)
  sortBy?: CustomerSortField = CustomerSortField.CREATED_AT;

  @ApiPropertyOptional({
    example: 'desc',
    enum: SortOrder,
    default: SortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder = SortOrder.DESC;

  @ApiPropertyOptional({ example: '2026-01-01' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateFrom?: Date;

  @ApiPropertyOptional({ example: '2026-12-31' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  dateTo?: Date;

  @ApiPropertyOptional({
    example: true,
    description: 'When true, return only loyalty members (loyalty points > 0)',
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === 'true' || value === true) return true;
    if (value === 'false' || value === false) return false;
    return undefined;
  })
  @IsBoolean()
  isMember?: boolean;
}
