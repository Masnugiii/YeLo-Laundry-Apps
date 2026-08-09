import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthenticatedEmployee } from '../interfaces/jwt-payload.interface';

export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedEmployee => {
    const request = context
      .switchToHttp()
      .getRequest<{ user: AuthenticatedEmployee }>();

    return request.user;
  },
);
