import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';
import { isAuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';

export const CurrentCustomer = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedCustomer => {
    const request = context.switchToHttp().getRequest<{ user: unknown }>();

    if (!isAuthenticatedCustomer(request.user)) {
      throw new Error('Customer authentication required');
    }

    return request.user;
  },
);
