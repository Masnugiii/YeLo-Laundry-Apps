import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  Max,
  Min,
} from 'class-validator';
import { DOCUMENT_COMPRESSION_MODES } from '../types/document-rules.types';

export class UpdateDocumentRulesDto {
  @ApiPropertyOptional({ example: 10485760 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(52_428_800)
  maxFileSizeBytes?: number;

  @ApiPropertyOptional({
    example: ['image/jpeg', 'image/png', 'application/pdf'],
  })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  allowedMimeTypes?: string[];

  @ApiPropertyOptional({ enum: DOCUMENT_COMPRESSION_MODES })
  @IsOptional()
  @IsIn([...DOCUMENT_COMPRESSION_MODES])
  compressionMode?: (typeof DOCUMENT_COMPRESSION_MODES)[number];

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  ocrEnabled?: boolean;
}
