import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdateReceiptSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  showLogo?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  showQRCode?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  footerText?: string | null;
}
