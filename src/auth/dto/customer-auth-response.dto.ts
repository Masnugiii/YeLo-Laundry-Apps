import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendOtpResponseDto {
  @ApiProperty({ example: '770e8400-e29b-41d4-a716-446655440002' })
  otpRequestId!: string;

  @ApiProperty({ example: 300 })
  expiresIn!: number;

  @ApiProperty({ example: '+62812****7890' })
  maskedPhone!: string;
}

export class CustomerAuthUserDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiProperty()
  fullName!: string;

  @ApiPropertyOptional()
  email?: string | null;

  @ApiPropertyOptional()
  photoUrl?: string | null;

  @ApiPropertyOptional({ example: 'CUS-0004827' })
  customerCode?: string;
}

export class CustomerAuthResponseDto {
  @ApiProperty()
  accessToken!: string;

  @ApiProperty()
  refreshToken!: string;

  @ApiProperty({ example: 'Bearer' })
  tokenType!: string;

  @ApiProperty({ example: 604800 })
  expiresIn!: number;

  @ApiProperty({ type: CustomerAuthUserDto })
  user!: CustomerAuthUserDto;
}
