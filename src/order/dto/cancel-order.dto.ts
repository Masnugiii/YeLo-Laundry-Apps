import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CancelOrderDto {
  @ApiProperty({ example: 'Customer request cancellation' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  reason!: string;
}
