import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  Max,
  Min,
} from 'class-validator';
import { BACKUP_SCHEDULES } from '../types/backup-settings.types';

export class UpdateBackupSettingsDto {
  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @ApiPropertyOptional({ enum: BACKUP_SCHEDULES })
  @IsOptional()
  @IsIn([...BACKUP_SCHEDULES])
  schedule?: (typeof BACKUP_SCHEDULES)[number];

  @ApiPropertyOptional({ example: 30 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3650)
  retentionDays?: number;
}
