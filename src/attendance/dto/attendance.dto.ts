import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AttendanceStatus } from '@prisma/client';
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

export class AttendanceQueryDto {
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
    description: 'Search by employee name or code',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiPropertyOptional({ enum: AttendanceStatus })
  @IsOptional()
  @IsEnum(AttendanceStatus)
  status?: AttendanceStatus;

  @ApiPropertyOptional({ example: 'shift-morning' })
  @IsOptional()
  @IsString()
  shiftId?: string;

  @ApiPropertyOptional({ example: '2026-08-08' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  date?: Date;

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

export class AttendanceLocationDto {
  @ApiProperty({ example: -6.2088 })
  @Type(() => Number)
  @IsNumber()
  latitude!: number;

  @ApiProperty({ example: 106.8456 })
  @Type(() => Number)
  @IsNumber()
  longitude!: number;

  @ApiPropertyOptional({ example: 12.5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  accuracy?: number;
}

export class CheckInDto extends AttendanceLocationDto {
  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiPropertyOptional({ example: 'shift-morning-id' })
  @IsOptional()
  @IsString()
  shiftId?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/checkin.jpg' })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiPropertyOptional({ example: 'Samsung Galaxy A54' })
  @IsOptional()
  @IsString()
  device?: string;

  @ApiPropertyOptional({ example: 'Arrived on time' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class CheckOutDto extends AttendanceLocationDto {
  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/checkout.jpg' })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiPropertyOptional({ example: 'Completed shift' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class BreakActionDto {
  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

  @ApiPropertyOptional({ example: 'Lunch break' })
  @IsOptional()
  @IsString()
  notes?: string;
}
