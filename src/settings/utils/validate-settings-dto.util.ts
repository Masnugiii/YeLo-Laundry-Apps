import { BadRequestException } from '@nestjs/common';
import { ClassConstructor, plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

export async function validateSettingsDto<T extends object>(
  cls: ClassConstructor<T>,
  plain: unknown,
): Promise<T> {
  const instance = plainToInstance(cls, plain, {
    enableImplicitConversion: true,
  });

  const errors = await validate(instance, {
    whitelist: true,
    forbidNonWhitelisted: true,
  });

  if (errors.length > 0) {
    throw new BadRequestException({
      message: 'Validation failed',
      errors: errors.map((error) => ({
        property: error.property,
        constraints: error.constraints,
      })),
    });
  }

  return instance;
}
