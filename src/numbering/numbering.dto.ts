import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { NUMBERING_TYPES } from './numbering.types';

export class UpdateNumberingSequenceDto {
  @ApiProperty({ enum: NUMBERING_TYPES })
  @IsString()
  @IsIn([...NUMBERING_TYPES])
  type!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(20)
  prefix?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  padding?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  dailyReset?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class NumberingTypeParamDto {
  @ApiProperty({ enum: NUMBERING_TYPES })
  @IsString()
  @IsIn([...NUMBERING_TYPES])
  type!: string;
}
