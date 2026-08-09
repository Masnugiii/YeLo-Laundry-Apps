import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsDate,
  IsEnum,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import {
  PayrollBonusType,
  PayrollDeductionType,
  PayrollPaymentMethod,
  PayrollPeriodType,
  PayrollRecordStatus,
} from './payroll.types';

export class AttendanceBonusDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  bonusAmount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  requiredAttendance?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  allowedLate?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  allowedLeave?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  allowedAbsent?: number;
}

export class UpdatePayrollSettingsDto {
  @IsOptional() @IsNumber() laundryKgRate?: number;
  @IsOptional() @IsNumber() laundryPieceRate?: number;
  @IsOptional() @IsNumber() ironingKgRate?: number;
  @IsOptional() @IsNumber() ironingPieceRate?: number;
  @IsOptional() @IsNumber() attendanceBonusPerDay?: number;
  @IsOptional() @IsNumber() managerWeeklySalary?: number;
  @IsOptional() @IsNumber() operatorWeeklySalary?: number;
  @IsOptional() @IsArray() payrollScheduleDays?: number[];
  @IsOptional() @IsEnum(['weekly', 'biweekly', 'monthly']) periodType?: PayrollPeriodType;
  @IsOptional() @ValidateNested() @Type(() => AttendanceBonusDto) attendanceBonus?: AttendanceBonusDto;
  @IsOptional() @IsNumber() laundryPricePerKg?: number;
  @IsOptional() @IsNumber() laundryPricePerItem?: number;
}

export class PayrollQueryDto {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) page?: number = 1;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(100) limit?: number = 25;
  @IsOptional() @IsUUID() employeeId?: string;
  @IsOptional() @IsString() role?: string;
  @IsOptional() @IsEnum(['DRAFT', 'CALCULATED', 'APPROVED', 'PAID']) status?: PayrollRecordStatus;
  @IsOptional() @Type(() => Date) @IsDate() periodStart?: Date;
  @IsOptional() @Type(() => Date) @IsDate() periodEnd?: Date;
}

export class CalculatePayrollDto {
  @ApiProperty()
  @Type(() => Date)
  @IsDate()
  periodStart!: Date;

  @ApiProperty()
  @Type(() => Date)
  @IsDate()
  periodEnd!: Date;
}

export class ApprovePayrollDto {
  @ApiProperty({ type: [String] })
  @IsArray()
  @IsUUID('4', { each: true })
  payrollIds!: string[];

  @IsOptional() @IsString() notes?: string;
}

export class PayPayrollDto {
  @ApiProperty()
  @IsUUID()
  payrollId!: string;

  @ApiProperty({ enum: ['CASH', 'TRANSFER', 'WALLET'] })
  @IsEnum(['CASH', 'TRANSFER', 'WALLET'])
  method!: PayrollPaymentMethod;

  @ApiProperty()
  @IsNumber()
  @Min(0.01)
  amount!: number;

  @IsOptional() @IsString() referenceNumber?: string;
  @IsOptional() @IsString() notes?: string;
}

export class ManualBonusDto {
  @IsEnum(['ATTENDANCE', 'PERFORMANCE', 'HOLIDAY', 'MANUAL'])
  type!: PayrollBonusType;

  @IsNumber() @Min(0) amount!: number;
  @IsOptional() @IsString() notes?: string;
}

export class ManualDeductionDto {
  @IsEnum(['ADVANCE', 'PENALTY', 'LOAN', 'OTHER'])
  type!: PayrollDeductionType;

  @IsNumber() @Min(0) amount!: number;
  @IsOptional() @IsString() notes?: string;
}

export class PayrollReportQueryDto {
  @IsOptional() @Type(() => Date) @IsDate() periodStart?: Date;
  @IsOptional() @Type(() => Date) @IsDate() periodEnd?: Date;
  @IsOptional() @IsEnum(['summary', 'detail', 'bonus', 'deduction']) reportType?: 'summary' | 'detail' | 'bonus' | 'deduction';
}
