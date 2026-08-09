import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { CustomerNoteCategory } from '../utils/customer-note-meta.util';

export class CreateCustomerNoteDto {
  @ApiPropertyOptional({ example: 'VIP Customer' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  title?: string;

  @ApiProperty({
    example: 'Customer always requests perfume-free laundry.',
  })
  @IsString()
  @IsNotEmpty()
  note!: string;

  @ApiProperty({
    enum: CustomerNoteCategory,
    example: CustomerNoteCategory.SERVICE,
    default: CustomerNoteCategory.OTHER,
  })
  @IsEnum(CustomerNoteCategory)
  category!: CustomerNoteCategory;

  @ApiPropertyOptional({ example: true, default: false })
  @IsOptional()
  @IsBoolean()
  isPinned?: boolean;
}
