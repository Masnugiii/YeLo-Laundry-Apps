import { plainToInstance, Type } from 'class-transformer';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  validateSync,
} from 'class-validator';

enum Environment {
  Development = 'development',
  Production = 'production',
  Test = 'test',
}

class EnvironmentVariables {
  @IsString()
  @IsNotEmpty()
  DATABASE_URL!: string;

  @IsString()
  @IsNotEmpty()
  JWT_SECRET!: string;

  @IsString()
  @IsNotEmpty()
  REFRESH_TOKEN_SECRET!: string;

  @IsEnum(Environment)
  @IsOptional()
  APP_ENV: Environment = Environment.Development;

  @IsString()
  @IsOptional()
  APP_NAME?: string;

  @IsString()
  @IsOptional()
  APP_HOST?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  PORT?: number;

  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @IsOptional()
  APP_PORT?: number;

  @IsString()
  @IsOptional()
  API_PREFIX?: string;

  @IsString()
  @IsOptional()
  CORS_ORIGINS?: string;

  @IsString()
  @IsOptional()
  JWT_EXPIRES_IN?: string;

  @IsString()
  @IsOptional()
  REFRESH_TOKEN_EXPIRES_IN?: string;

  @IsString()
  @IsOptional()
  REDIS_HOST?: string;

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  REDIS_PORT?: number;

  @IsString()
  @IsOptional()
  BODY_LIMIT?: string;

  @IsString()
  @IsOptional()
  DEV_OTP_PHONE_WHITELIST?: string;
}

export function validateEnv(config: Record<string, unknown>) {
  const validated = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validated, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    const messages = errors
      .flatMap((error) => Object.values(error.constraints ?? {}))
      .join('\n');

    throw new Error(`Environment validation failed:\n${messages}`);
  }

  return validated;
}
