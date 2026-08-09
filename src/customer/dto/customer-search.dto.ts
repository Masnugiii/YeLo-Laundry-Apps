import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsNotEmpty, IsOptional, IsString, Max, Min, MinLength } from 'class-validator';

export class CustomerSearchDto {
  @ApiProperty({
    example: '0811',
    description: 'Phone, name, or customer code (minimum 3 characters)',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  q!: string;

  @ApiPropertyOptional({ example: 10, default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 10;
}
