import {
  ArgumentsHost,
  BadRequestException,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { ApiErrorResponse } from '../interfaces/api-response.interface';

@Catch(BadRequestException)
export class ValidationExceptionFilter implements ExceptionFilter {
  catch(exception: BadRequestException, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    let message = 'Validation failed';
    let errors: Record<string, unknown> | unknown[] = {};

    if (typeof exceptionResponse === 'string') {
      message = exceptionResponse;
    } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
      const body = exceptionResponse as Record<string, unknown>;
      message = (body.message as string) ?? message;

      if (Array.isArray(body.message)) {
        errors = body.message;
        message = 'Validation failed';
      } else if (body.errors) {
        errors = body.errors as Record<string, unknown>;
      }
    }

    const payload: ApiErrorResponse = {
      success: false,
      message,
      errors,
    };

    response.status(status).json(payload);
  }
}
