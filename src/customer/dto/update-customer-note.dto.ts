import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { CustomerNoteCategory } from '../utils/customer-note-meta.util';

export class UpdateCustomerNoteDto {
  @ApiPropertyOptional({ example: 'VIP Customer' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  title?: string;

  @ApiPropertyOptional({
    example: 'Customer always requests perfume-free laundry.',
  })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  note?: string;

  @ApiPropertyOptional({
    enum: CustomerNoteCategory,
    example: CustomerNoteCategory.SERVICE,
  })
  @IsOptional()
  @IsEnum(CustomerNoteCategory)
  category?: CustomerNoteCategory;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isPinned?: boolean;
}
