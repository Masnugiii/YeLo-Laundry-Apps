import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '../constants/roles.constant';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { ALLOW_CUSTOMER_ACTOR_KEY } from '../../customer/decorators/allow-customer-actor.decorator';
import { isAuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';
import { AuthenticatedEmployee } from '../interfaces/jwt-payload.interface';

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const allowCustomerActor = this.reflector.getAllAndOverride<boolean>(
      ALLOW_CUSTOMER_ACTOR_KEY,
      [context.getHandler(), context.getClass()],
    );

    const request = context
      .switchToHttp()
      .getRequest<{ user: AuthenticatedEmployee | unknown }>();
    const user = request.user;

    if (allowCustomerActor && isAuthenticatedCustomer(user)) {
      return true;
    }

    const employee = user as AuthenticatedEmployee;

    if (!employee?.roles?.length) {
      this.logger.warn(
        `Forbidden access: employee ${employee?.employeeId ?? 'unknown'} has no roles`,
      );
      throw new ForbiddenException('Insufficient role permissions');
    }

    const hasRole = requiredRoles.some((role) => employee.roles.includes(role));

    if (!hasRole) {
      this.logger.warn(
        `Forbidden access: employee ${employee.employeeId} missing roles [${requiredRoles.join(', ')}]`,
      );
      throw new ForbiddenException('Insufficient role permissions');
    }

    return true;
  }
}
