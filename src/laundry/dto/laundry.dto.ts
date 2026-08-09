import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';
import { ProductionStatus } from '../utils/production-meta.util';

export class LaundryOrderQueryDto {
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
    example: 'YL-20260808',
    description: 'Search by order number, customer name, or phone',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({
    example: 'WASHING',
    enum: [
      'RECEIVED',
      'WAITING_WASH',
      'WASHING',
      'WAITING_DRY',
      'DRYING',
      'WAITING_IRON',
      'IRONING',
      'QUALITY_CHECK',
      'READY',
      'COMPLETED',
    ],
  })
  @IsOptional()
  @IsString()
  status?: ProductionStatus;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440001' })
  @IsOptional()
  @IsUUID()
  employeeId?: string;

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

  @ApiPropertyOptional({ example: 'NORMAL', enum: ['NORMAL', 'EXPRESS', 'VIP'] })
  @IsOptional()
  @IsEnum(['NORMAL', 'EXPRESS', 'VIP'])
  priority?: 'NORMAL' | 'EXPRESS' | 'VIP';

  @ApiPropertyOptional({
    example: 'Wash & Fold',
    description: 'Filter by service name (partial match)',
  })
  @IsOptional()
  @IsString()
  service?: string;

  @ApiPropertyOptional({
    example: 'delayed',
    enum: ['delayed', 'on_track'],
    description: 'Filter by SLA delay status',
  })
  @IsOptional()
  @IsEnum(['delayed', 'on_track'])
  delayStatus?: 'delayed' | 'on_track';
}

export class ProductionActionDto {
  @ApiPropertyOptional({ example: 'Started washing batch A' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class QualityCheckDto {
  @ApiProperty({ example: true })
  passed!: boolean;

  @ApiPropertyOptional({ example: 'No stain remaining.' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({
    example: 'WAITING_WASH',
    enum: ['WAITING_WASH', 'WAITING_IRON'],
    description: 'Required when passed is false',
  })
  @IsOptional()
  @IsEnum(['WAITING_WASH', 'WAITING_IRON'])
  reworkStage?: 'WAITING_WASH' | 'WAITING_IRON';

  @ApiPropertyOptional({ example: 'Stain found on collar' })
  @IsOptional()
  @IsString()
  reason?: string;
}
