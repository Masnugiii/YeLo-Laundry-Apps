import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

class UpdateNotificationToggleSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notify_new_order?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notify_payment?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notify_ironing_finished?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notify_pickup_delivery?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  notify_wallet?: boolean;
}

class UpdateNotificationTemplateDto {
  @ApiPropertyOptional()
  @IsUUID()
  id!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(200)
  title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(5000)
  body?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateNotificationSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateNotificationToggleSettingsDto)
  settings?: UpdateNotificationToggleSettingsDto;

  @ApiPropertyOptional({ type: [UpdateNotificationTemplateDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UpdateNotificationTemplateDto)
  templates?: UpdateNotificationTemplateDto[];
}
