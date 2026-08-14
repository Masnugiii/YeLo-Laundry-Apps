import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';

class UpdateQrisPaymentSettingsDto {
  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/qris.png' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  qrImageUrl?: string | null;

  @ApiPropertyOptional({
    description: 'EMV QR payload used to render QR code in customer app',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  qrPayload?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  instructions?: string;
}

class UpdateBankTransferPaymentSettingsDto {
  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ example: 'BCA' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  bankName?: string;

  @ApiPropertyOptional({ example: '1234567890' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  accountNumber?: string;

  @ApiPropertyOptional({ example: 'Yelo Laundry' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  accountHolder?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  instructions?: string;
}

export class UpdatePaymentSettingsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateQrisPaymentSettingsDto)
  qris?: UpdateQrisPaymentSettingsDto;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateBankTransferPaymentSettingsDto)
  bankTransfer?: UpdateBankTransferPaymentSettingsDto;
}
