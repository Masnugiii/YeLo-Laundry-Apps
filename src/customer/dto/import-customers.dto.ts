import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Gender } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsDate,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export enum DuplicateImportStrategy {
  SKIP = 'SKIP',
  UPDATE = 'UPDATE',
  CANCEL = 'CANCEL',
}

export class ImportCustomerRowDto {
  @ApiProperty({ example: 'Andi Wijaya' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  fullName!: string;

  @ApiProperty({ example: '081122334455' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  phone!: string;

  @ApiPropertyOptional({ example: 'andi@email.com' })
  @IsOptional()
  @IsString()
  @MaxLength(150)
  email?: string;

  @ApiPropertyOptional({ enum: Gender })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ example: '1990-05-15' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  birthDate?: Date;

  @ApiPropertyOptional({ example: 'Jl. Merdeka No. 10' })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({ example: 'MEMBER' })
  @IsOptional()
  @IsString()
  memberStatus?: string;
}

export class ImportCustomersDto {
  @ApiProperty({ enum: DuplicateImportStrategy, example: DuplicateImportStrategy.SKIP })
  @IsEnum(DuplicateImportStrategy)
  duplicateStrategy!: DuplicateImportStrategy;

  @ApiProperty({ type: [ImportCustomerRowDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ImportCustomerRowDto)
  rows!: ImportCustomerRowDto[];
}
