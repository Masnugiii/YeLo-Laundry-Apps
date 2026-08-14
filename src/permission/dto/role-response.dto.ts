import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { RoleCode } from '@prisma/client';

export class RoleResponseDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id!: string;

  @ApiProperty({ enum: RoleCode, example: RoleCode.cashier })
  code!: RoleCode;

  @ApiProperty({ example: 'Kasir' })
  name!: string;

  @ApiPropertyOptional({ example: 'Cashier and front desk operations' })
  description?: string | null;

  @ApiProperty({ example: 'CASHIER' })
  apiRole!: string;

  @ApiProperty({ example: true })
  isActive!: boolean;
}
