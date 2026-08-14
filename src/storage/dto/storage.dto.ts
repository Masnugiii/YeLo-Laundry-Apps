import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class AssignStorageDto {
  @ApiProperty({ example: 'A' })
  @IsString()
  lockerCode!: string;

  @ApiProperty({ example: 5 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(15)
  boxNumber!: number;
}

export class MoveStorageDto extends AssignStorageDto {}

export class StorageSearchQueryDto {
  @ApiPropertyOptional({ example: 'A-05' })
  @IsOptional()
  @IsString()
  q?: string;

  @ApiPropertyOptional({ example: 'A' })
  @IsOptional()
  @IsString()
  lockerCode?: string;

  @ApiPropertyOptional({ enum: ['all', 'available', 'occupied', 'ready_for_pickup'] })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;
}
