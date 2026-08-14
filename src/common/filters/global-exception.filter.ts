import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';
import { ApiErrorResponse } from '../interfaces/api-response.interface';
import {
  formatPrismaErrorForLog,
  isPrismaConnectionError,
  isPrismaSchemaMismatchError,
} from '../../database/prisma/prisma.service';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    // Prefer dedicated HttpException filters, but never leak a 500 for known HTTP errors
    // if filter order/registration misses them.
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      let message = exception.message;
      let errors: Record<string, unknown> | unknown[] = {};

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (
        typeof exceptionResponse === 'object' &&
        exceptionResponse !== null
      ) {
        const body = exceptionResponse as Record<string, unknown>;
        message = Array.isArray(body.message)
          ? 'Request failed'
          : ((body.message as string) ?? message);
        errors = (body.error as Record<string, unknown>) ?? { statusCode: status };
      }

      response.status(status).json({
        success: false,
        message,
        errors,
      } satisfies ApiErrorResponse);
      return;
    }

    if (isPrismaConnectionError(exception)) {
      this.logger.error(
        `Database unavailable: ${formatPrismaErrorForLog(exception)}`,
      );
      response.status(HttpStatus.SERVICE_UNAVAILABLE).json({
        success: false,
        message: 'Database temporarily unavailable. Please try again.',
        errors: {},
      } satisfies ApiErrorResponse);
      return;
    }

    if (isPrismaSchemaMismatchError(exception)) {
      this.logger.error(
        `Database schema mismatch: ${formatPrismaErrorForLog(exception)}`,
      );
      response.status(HttpStatus.SERVICE_UNAVAILABLE).json({
        success: false,
        message: 'Database schema is not ready. Please try again shortly.',
        errors: {},
      } satisfies ApiErrorResponse);
      return;
    }

    this.logger.error(
      exception instanceof Error
        ? `${exception.message} ${formatPrismaErrorForLog(exception)}`
        : `Unknown error ${formatPrismaErrorForLog(exception)}`,
      exception instanceof Error ? exception.stack : undefined,
    );

    const payload: ApiErrorResponse = {
      success: false,
      message: 'Internal server error',
      errors: {},
    };

    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json(payload);
  }
}
