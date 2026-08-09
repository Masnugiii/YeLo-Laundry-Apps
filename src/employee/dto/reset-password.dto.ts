import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import {
  PASSWORD_PATTERN,
  PASSWORD_VALIDATION_MESSAGE,
} from './change-password.dto';

export class ResetPasswordDto {
  @ApiProperty({ example: 'Admin123!' })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  @MaxLength(128)
  @Matches(PASSWORD_PATTERN, { message: PASSWORD_VALIDATION_MESSAGE })
  newPassword!: string;
}
