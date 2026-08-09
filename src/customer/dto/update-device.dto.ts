import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { DevicePlatformApi } from '../utils/customer-device-meta.util';

export class UpdateDeviceDto {
  @ApiPropertyOptional({ example: 'Nugroho iPhone' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  deviceName?: string;

  @ApiPropertyOptional({ example: 'yyyyyyyyyyyyyyyy' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  deviceToken?: string;

  @ApiPropertyOptional({ example: '1.0.1' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  appVersion?: string;

  @ApiPropertyOptional({ example: '18.3' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  osVersion?: string;

  @ApiPropertyOptional({ enum: DevicePlatformApi, example: DevicePlatformApi.IOS })
  @IsOptional()
  @IsEnum(DevicePlatformApi)
  devicePlatform?: DevicePlatformApi;
}
