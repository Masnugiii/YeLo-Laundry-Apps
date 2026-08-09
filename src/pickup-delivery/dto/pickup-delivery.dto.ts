import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

export class JobQueryDto {
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

  @ApiPropertyOptional({ example: 'YL-20260808' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ example: 'REQUESTED' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ example: '660e8400-e29b-41d4-a716-446655440003' })
  @IsOptional()
  @IsUUID()
  driverId?: string;

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
}

export class RequestPickupDto {
  @ApiPropertyOptional({ example: '990e8400-e29b-41d4-a716-446655440020' })
  @IsOptional()
  @IsUUID()
  pickupAddressId?: string;

  @ApiPropertyOptional({ example: '2026-08-08T10:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  scheduledPickupAt?: Date;

  @ApiPropertyOptional({ example: 'Pickup from home' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class RequestDeliveryDto {
  @ApiPropertyOptional({ example: '990e8400-e29b-41d4-a716-446655440021' })
  @IsOptional()
  @IsUUID()
  deliveryAddressId?: string;

  @ApiPropertyOptional({ example: '2026-08-10T14:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  scheduledDeliveryAt?: Date;

  @ApiPropertyOptional({ example: 'Deliver after 2 PM' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class AssignDriverDto {
  @ApiProperty({ example: '660e8400-e29b-41d4-a716-446655440003' })
  @IsUUID()
  driverId!: string;

  @ApiPropertyOptional({ example: 5.2 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  estimatedDistanceKm?: number;

  @ApiPropertyOptional({ example: 25 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  estimatedDurationMinutes?: number;
}

export class TripLocationDto {
  @ApiPropertyOptional({ example: -6.2088 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  latitude?: number;

  @ApiPropertyOptional({ example: 106.8456 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  longitude?: number;

  @ApiPropertyOptional({ example: 35 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  speed?: number;
}

export class PickupSuccessDto {
  @ApiProperty({ example: 'https://cdn.example.com/pickup-proof.jpg' })
  @IsString()
  photoUrl!: string;

  @ApiPropertyOptional({ example: 'Laundry received successfully.' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class DeliverySuccessDto {
  @ApiProperty({ example: 'https://cdn.example.com/delivery-proof.jpg' })
  @IsString()
  photoUrl!: string;

  @ApiProperty({ example: 'Budi' })
  @IsString()
  receiverName!: string;

  @ApiPropertyOptional({ example: 'Delivered successfully.' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class RecordTrackingDto {
  @ApiProperty({ example: -6.2088 })
  @Type(() => Number)
  @IsNumber()
  latitude!: number;

  @ApiProperty({ example: 106.8456 })
  @Type(() => Number)
  @IsNumber()
  longitude!: number;

  @ApiPropertyOptional({ example: 42 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  speed?: number;
}
