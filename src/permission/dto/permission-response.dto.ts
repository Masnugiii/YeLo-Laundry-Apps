import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class PermissionResponseDto {
  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  id!: string;

  @ApiProperty({ example: 'employee.view' })
  code!: string;

  @ApiProperty({ example: 'View Employee' })
  name!: string;

  @ApiProperty({ example: 'employee' })
  module!: string;

  @ApiPropertyOptional({ example: 'Allows viewing employee records' })
  description?: string | null;
}
