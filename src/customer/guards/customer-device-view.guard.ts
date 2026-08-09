import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { ROLES } from '../../auth/constants/roles.constant';
import { AuthenticatedEmployee } from '../../auth/interfaces/jwt-payload.interface';
import { isAuthenticatedCustomer } from '../interfaces/authenticated-customer.interface';

@Injectable()
export class CustomerDeviceViewGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: AuthenticatedEmployee | unknown;
      params: { customerId: string };
    }>();

    const user = request.user;
    const { customerId } = request.params;

    if (isAuthenticatedCustomer(user) && user.customerId === customerId) {
      return true;
    }

    const employee = user as AuthenticatedEmployee;

    if (
      employee?.roles?.some(
        (role) => role === ROLES.OWNER || role === ROLES.MANAGER,
      )
    ) {
      return true;
    }

    throw new ForbiddenException('Insufficient permissions to view devices');
  }
}
