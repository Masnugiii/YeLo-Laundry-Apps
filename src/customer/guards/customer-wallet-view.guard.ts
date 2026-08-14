import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { AuthenticatedEmployee } from '../../auth/interfaces/jwt-payload.interface';
import { isAuthenticatedCustomer } from '../interfaces/authenticated-customer.interface';

function isAuthenticatedEmployee(
  user: unknown,
): user is AuthenticatedEmployee {
  return (
    typeof user === 'object' &&
    user !== null &&
    'employeeId' in user &&
    typeof (user as AuthenticatedEmployee).employeeId === 'string' &&
    Array.isArray((user as AuthenticatedEmployee).roles)
  );
}

@Injectable()
export class CustomerWalletViewGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: unknown;
      params: { customerId: string };
    }>();

    const user = request.user;
    const { customerId } = request.params;

    if (isAuthenticatedCustomer(user)) {
      if (user.customerId === customerId) {
        return true;
      }

      throw new ForbiddenException(
        'Only the account owner can access this resource',
      );
    }

    if (isAuthenticatedEmployee(user)) {
      return true;
    }

    throw new ForbiddenException('Unauthorized');
  }
}
