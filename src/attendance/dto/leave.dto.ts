import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export enum LeaveTypeDto {
  ANNUAL = 'ANNUAL',
  SICK = 'SICK',
  EMERGENCY = 'EMERGENCY',
  MATERNITY = 'MATERNITY',
  UNPAID = 'UNPAID',
}

export class LeaveQueryDto {
  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiPropertyOptional({ example: 'PENDING' })
  @IsOptional()
  @IsString()
  status?: 'PENDING' | 'APPROVED' | 'REJECTED';

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

export class CreateLeaveDto {
  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiProperty({ enum: LeaveTypeDto, example: LeaveTypeDto.ANNUAL })
  @IsEnum(LeaveTypeDto)
  leaveType!: LeaveTypeDto;

  @ApiProperty({ example: '2026-08-10' })
  @Type(() => Date)
  @IsDate()
  startDate!: Date;

  @ApiProperty({ example: '2026-08-12' })
  @Type(() => Date)
  @IsDate()
  endDate!: Date;

  @ApiProperty({ example: 'Family vacation' })
  @IsString()
  reason!: string;
}

export class UpdateLeaveDto {
  @ApiPropertyOptional({ enum: LeaveTypeDto })
  @IsOptional()
  @IsEnum(LeaveTypeDto)
  leaveType?: LeaveTypeDto;

  @ApiPropertyOptional({ example: '2026-08-10' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startDate?: Date;

  @ApiPropertyOptional({ example: '2026-08-12' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endDate?: Date;

  @ApiPropertyOptional({ example: 'Updated reason' })
  @IsOptional()
  @IsString()
  reason?: string;
}

export class RejectLeaveDto {
  @ApiProperty({ example: 'Insufficient leave balance' })
  @IsString()
  reason!: string;
}
