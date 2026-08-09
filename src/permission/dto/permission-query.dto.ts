import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class PermissionQueryDto {
  @ApiPropertyOptional({
    example: 'employee',
    description: 'Filter by permission module',
  })
  @IsOptional()
  @IsString()
  module?: string;

  @ApiPropertyOptional({
    example: 'view',
    description: 'Search by code, name, module, or description',
  })
  @IsOptional()
  @IsString()
  keyword?: string;
}
