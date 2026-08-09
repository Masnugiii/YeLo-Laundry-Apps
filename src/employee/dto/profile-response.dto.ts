import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ProfileResponseDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id!: string;

  @ApiProperty({ example: 'EMP0001' })
  employeeCode!: string;

  @ApiProperty({ example: 'Owner' })
  fullName!: string;

  @ApiProperty({ example: '081234567890' })
  phone!: string;

  @ApiPropertyOptional({ example: 'owner@example.com' })
  email!: string | null;

  @ApiPropertyOptional({
    example: 'https://cdn.example.com/avatars/owner.jpg',
  })
  avatar!: string | null;

  @ApiProperty({ example: ['OWNER'], type: [String] })
  roles!: string[];

  @ApiProperty({ example: ['dashboard', 'orders'], type: [String] })
  permissions!: string[];

  @ApiProperty({ example: 'ACTIVE' })
  status!: string;

  @ApiProperty({ example: '2026-01-01T00:00:00.000Z' })
  createdAt!: Date;

  @ApiProperty({ example: '2026-08-08T06:00:00.000Z' })
  updatedAt!: Date;

  @ApiPropertyOptional({ example: '2026-08-08T06:30:00.000Z' })
  lastLoginAt!: Date | null;
}
