import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

const TIME_PATTERN = /^([01]\d|2[0-3]):[0-5]\d$/;

class UpdateAttendanceGpsDto {
  @ApiPropertyOptional({ example: -7.7563 })
  @IsOptional()
  @IsNumber()
  @Min(-90)
  @Max(90)
  officeLatitude?: number;

  @ApiPropertyOptional({ example: 113.2155 })
  @IsOptional()
  @IsNumber()
  @Min(-180)
  @Max(180)
  officeLongitude?: number;

  @ApiPropertyOptional({ example: 100 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(10000)
  officeRadiusMeters?: number;
}

export class UpdateAttendanceSettingsDto {
  @ApiPropertyOptional({ example: '08:00' })
  @IsOptional()
  @IsString()
  @Matches(TIME_PATTERN, { message: 'workStartTime must be HH:mm' })
  workStartTime?: string;

  @ApiPropertyOptional({ example: '17:00' })
  @IsOptional()
  @IsString()
  @Matches(TIME_PATTERN, { message: 'workEndTime must be HH:mm' })
  workEndTime?: string;

  @ApiPropertyOptional({ example: 15 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(180)
  lateToleranceMinutes?: number;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  overtimeEnabled?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateAttendanceGpsDto)
  gps?: UpdateAttendanceGpsDto | null;
}
