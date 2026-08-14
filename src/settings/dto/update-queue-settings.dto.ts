import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { UpdateNumberingSequenceDto } from '../../numbering/numbering.dto';

export class UpdateQueueSettingsDto {
  @ApiPropertyOptional({ example: 'A' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  prefix?: string;

  @ApiPropertyOptional({ example: 4288 })
  @IsOptional()
  @IsInt()
  @Min(1)
  startingNumber?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  dailyReset?: boolean;
}

export class UpdateNumberingSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateQueueSettingsDto)
  queue?: UpdateQueueSettingsDto;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateNumberingSequenceDto)
  sequence?: UpdateNumberingSequenceDto;
}
