import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { isAuthenticatedCustomer } from '../interfaces/authenticated-customer.interface';

@Injectable()
export class CustomerSelfGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: unknown;
      params: { customerId: string };
    }>();

    const user = request.user;
    const { customerId } = request.params;

    if (isAuthenticatedCustomer(user) && user.customerId === customerId) {
      return true;
    }

    throw new ForbiddenException(
      'Only the account owner can access this resource',
    );
  }
}
