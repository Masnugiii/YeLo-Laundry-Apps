import { ApiProperty } from '@nestjs/swagger';

export class RefreshResponseDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  accessToken!: string;

  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440000.b2c3d4e5f6...',
  })
  refreshToken!: string;
}
