import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsUUID } from 'class-validator';

export class AssignPermissionsDto {
  @ApiProperty({
    example: [
      '550e8400-e29b-41d4-a716-446655440001',
      '550e8400-e29b-41d4-a716-446655440002',
    ],
    description: 'Permission UUIDs to assign (replaces all existing assignments)',
    type: [String],
  })
  @IsArray()
  @IsUUID('4', { each: true })
  permissionIds!: string[];
}
