import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: '081234567890',
    description: 'Employee phone number',
  })
  @IsString()
  @IsNotEmpty({ message: 'Phone is required' })
  phone!: string;

  @ApiProperty({
    example: 'admin123',
    description: 'Account password',
    minLength: 6,
  })
  @IsString()
  @IsNotEmpty({ message: 'Password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters' })
  password!: string;
}
