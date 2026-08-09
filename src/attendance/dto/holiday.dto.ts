import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateHolidayDto {
  @ApiProperty({ example: 'Independence Day' })
  @IsString()
  name!: string;

  @ApiProperty({ example: '2026-08-17' })
  @Type(() => Date)
  @IsDate()
  date!: Date;

  @ApiPropertyOptional({ example: 'National holiday' })
  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateHolidayDto {
  @ApiPropertyOptional({ example: 'Independence Day' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ example: '2026-08-17' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  date?: Date;

  @ApiPropertyOptional({ example: 'National holiday' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
