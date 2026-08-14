import { ApiProperty } from '@nestjs/swagger';

export class LoginUserDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id!: string;

  @ApiProperty({ example: 'EMP0001' })
  employeeCode!: string;

  @ApiProperty({ example: 'Owner' })
  fullName!: string;

  @ApiProperty({ example: '081234567890' })
  phone!: string;

  @ApiProperty({ example: ['OWNER'], type: [String] })
  roles!: string[];

  @ApiProperty({ example: ['dashboard', 'orders'], type: [String] })
  permissions!: string[];
}

export class LoginResponseDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  accessToken!: string;

  @ApiProperty({ type: LoginUserDto })
  user!: LoginUserDto;
}
