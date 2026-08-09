import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { DevicePlatformApi } from '../utils/customer-device-meta.util';

export class RegisterDeviceDto {
  @ApiPropertyOptional({ example: 'Nugroho iPhone' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  deviceName?: string;

  @ApiProperty({ enum: DevicePlatformApi, example: DevicePlatformApi.IOS })
  @IsEnum(DevicePlatformApi)
  devicePlatform!: DevicePlatformApi;

  @ApiProperty({ example: 'xxxxxxxxxxxxxxxx' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  deviceToken!: string;

  @ApiPropertyOptional({ example: '1.0.0' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  appVersion?: string;

  @ApiPropertyOptional({ example: '18.2' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  osVersion?: string;
}
