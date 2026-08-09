import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { EmployeeStatusDto } from './employee-status.dto';

export class CreateEmployeeDto {
  @ApiProperty({ example: 'EMP0007' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  employeeCode!: string;

  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  fullName!: string;

  @ApiProperty({ example: '081234567890' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  phone!: string;

  @ApiPropertyOptional({ example: 'john@example.com' })
  @IsOptional()
  @IsEmail()
  @MaxLength(150)
  email?: string;

  @ApiProperty({ example: 'secret123', minLength: 6 })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  @MaxLength(128)
  password!: string;

  @ApiProperty({ example: 'ACTIVE', enum: EmployeeStatusDto })
  @IsEnum(EmployeeStatusDto)
  status!: EmployeeStatusDto;

  @ApiPropertyOptional({ example: 'Kasir' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  position?: string;
}
