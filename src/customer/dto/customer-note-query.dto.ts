import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { CustomerNoteCategory } from '../utils/customer-note-meta.util';

export class CustomerNoteQueryDto {
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
    example: 'perfume',
    description: 'Search by title or note content',
  })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({
    enum: CustomerNoteCategory,
    example: CustomerNoteCategory.SERVICE,
    description: 'Filter by note category',
  })
  @IsOptional()
  @IsEnum(CustomerNoteCategory)
  category?: CustomerNoteCategory;
}
