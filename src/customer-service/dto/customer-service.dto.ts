import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { TicketStatus } from '@prisma/client';
import { CS_CATEGORIES, CsCategory } from '../utils/category.util';

export class TicketQueryDto {
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
    description: 'Search by customer name, phone, or subject',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 'TRACKING_ORDER', enum: CS_CATEGORIES })
  @IsOptional()
  @IsEnum(CS_CATEGORIES)
  category?: CsCategory;

  @ApiPropertyOptional({ example: 'OPEN', enum: TicketStatus })
  @IsOptional()
  @IsEnum(TicketStatus)
  status?: TicketStatus;
}

export class UpdateTicketDto {
  @ApiPropertyOptional({ example: 'IN_PROGRESS', enum: TicketStatus })
  @IsOptional()
  @IsEnum(TicketStatus)
  status?: TicketStatus;

  @ApiPropertyOptional({ example: 'KOMPLAIN', enum: CS_CATEGORIES })
  @IsOptional()
  @IsEnum(CS_CATEGORIES)
  category?: CsCategory;

  @ApiPropertyOptional({ example: 'Complaint about stained shirt' })
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  subject?: string;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440003' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;
}

export class CreateMessageDto {
  @ApiProperty({ example: 'Terima kasih sudah menghubungi kami.' })
  @IsString()
  @MinLength(1)
  message!: string;
}
