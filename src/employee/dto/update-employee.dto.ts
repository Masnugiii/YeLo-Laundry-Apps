import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { EmployeeStatusDto } from './employee-status.dto';

export class UpdateEmployeeDto {
  @ApiPropertyOptional({ example: 'EMP0007' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  employeeCode?: string;

  @ApiPropertyOptional({ example: 'John Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  fullName?: string;

  @ApiPropertyOptional({ example: '081234567890' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({ example: 'john@example.com' })
  @IsOptional()
  @IsEmail()
  @MaxLength(150)
  email?: string;

  @ApiPropertyOptional({ example: 'newsecret123', minLength: 6 })
  @IsOptional()
  @IsString()
  @MinLength(6)
  @MaxLength(128)
  password?: string;

  @ApiPropertyOptional({ example: 'ACTIVE', enum: EmployeeStatusDto })
  @IsOptional()
  @IsEnum(EmployeeStatusDto)
  status?: EmployeeStatusDto;

  @ApiPropertyOptional({ example: 'Kasir' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  position?: string;
}
