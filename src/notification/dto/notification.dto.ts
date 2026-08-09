import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';
import {
  API_NOTIFICATION_PRIORITIES,
  API_NOTIFICATION_TYPES,
  NOTIFICATION_CHANNELS,
  NOTIFICATION_STATUSES,
} from '../constants/notification.constants';

export class NotificationQueryDto {
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

  @ApiPropertyOptional({ example: 'ORDER', enum: API_NOTIFICATION_TYPES })
  @IsOptional()
  @IsEnum(API_NOTIFICATION_TYPES)
  type?: string;

  @ApiPropertyOptional({ example: 'NORMAL', enum: API_NOTIFICATION_PRIORITIES })
  @IsOptional()
  @IsEnum(API_NOTIFICATION_PRIORITIES)
  priority?: string;

  @ApiPropertyOptional({ example: 'SENT', enum: NOTIFICATION_STATUSES })
  @IsOptional()
  @IsEnum(NOTIFICATION_STATUSES)
  status?: string;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isRead?: boolean;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440003' })
  @IsOptional()
  @IsUUID()
  recipient?: string;

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

  @ApiPropertyOptional({ example: 'YL-20260808' })
  @IsOptional()
  @IsString()
  search?: string;
}

export class SendNotificationDto {
  @ApiProperty({ example: 'Order Ready' })
  @IsString()
  title!: string;

  @ApiProperty({ example: 'Your order YL-20260808-000001 is ready for pickup.' })
  @IsString()
  message!: string;

  @ApiProperty({ example: 'ORDER', enum: API_NOTIFICATION_TYPES })
  @IsEnum(API_NOTIFICATION_TYPES)
  type!: string;

  @ApiPropertyOptional({ example: 'NORMAL', enum: API_NOTIFICATION_PRIORITIES })
  @IsOptional()
  @IsEnum(API_NOTIFICATION_PRIORITIES)
  priority?: string;

  @ApiPropertyOptional({
    example: ['IN_APP'],
    enum: NOTIFICATION_CHANNELS,
    isArray: true,
  })
  @IsOptional()
  @IsArray()
  @IsEnum(NOTIFICATION_CHANNELS, { each: true })
  channels?: string[];

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440003' })
  @IsOptional()
  @IsUUID()
  recipientEmployeeId?: string;

  @ApiPropertyOptional({ example: '990e8400-e29b-41d4-a716-446655440005' })
  @IsOptional()
  @IsUUID()
  recipientCustomerId?: string;

  @ApiPropertyOptional({ example: 'ee0e8400-e29b-41d4-a716-446655440010' })
  @IsOptional()
  @IsUUID()
  orderId?: string;

  @ApiPropertyOptional({ example: 'YL-20260808-000001' })
  @IsOptional()
  @IsString()
  orderNumber?: string;

  @ApiPropertyOptional({ example: 'Andi Wijaya' })
  @IsOptional()
  @IsString()
  customerName?: string;
}
