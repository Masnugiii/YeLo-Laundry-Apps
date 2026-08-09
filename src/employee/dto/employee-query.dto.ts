import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { Role, ROLES } from '../../auth/constants/roles.constant';
import { EmployeeStatusDto } from './employee-status.dto';

export enum EmployeeSortField {
  CREATED_AT = 'createdAt',
  UPDATED_AT = 'updatedAt',
  FULL_NAME = 'fullName',
  EMPLOYEE_CODE = 'employeeCode',
}

export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export class EmployeeQueryDto {
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
    example: 'john',
    description: 'Search across employee code, full name, phone, and email',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 'EMP0001' })
  @IsOptional()
  @IsString()
  employeeCode?: string;

  @ApiPropertyOptional({ example: 'John Doe' })
  @IsOptional()
  @IsString()
  fullName?: string;

  @ApiPropertyOptional({ example: '081234567890' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: 'john@example.com' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: 'CASHIER', enum: ROLES })
  @IsOptional()
  @IsEnum(ROLES)
  role?: Role;

  @ApiPropertyOptional({ example: 'ACTIVE', enum: EmployeeStatusDto })
  @IsOptional()
  @IsEnum(EmployeeStatusDto)
  status?: EmployeeStatusDto;

  @ApiPropertyOptional({
    example: false,
    description: 'When true, return only soft-deleted employees',
  })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  deleted?: boolean;

  @ApiPropertyOptional({
    example: 'createdAt',
    enum: EmployeeSortField,
    default: EmployeeSortField.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(EmployeeSortField)
  sortBy?: EmployeeSortField = EmployeeSortField.CREATED_AT;

  @ApiPropertyOptional({
    example: 'desc',
    enum: SortOrder,
    default: SortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder = SortOrder.DESC;
}
