import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class CustomerAddressQueryDto {
  @ApiPropertyOptional({
    example: 'Rumah',
    description:
      'Filter by address label or address text (searches address detail and district)',
  })
  @IsOptional()
  @IsString()
  label?: string;

  @ApiPropertyOptional({
    example: 'Nugroho',
    description: 'Filter by recipient name',
  })
  @IsOptional()
  @IsString()
  recipientName?: string;

  @ApiPropertyOptional({
    example: '0812',
    description: 'Filter by phone number',
  })
  @IsOptional()
  @IsString()
  phone?: string;
}
