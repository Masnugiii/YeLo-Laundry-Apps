import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';
import { ROLES } from '../constants/roles.constant';
import { ALLOW_CUSTOMER_ACTOR_KEY } from '../../customer/decorators/allow-customer-actor.decorator';
import { isAuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';
import { AuthenticatedEmployee } from '../interfaces/jwt-payload.interface';

@Injectable()
export class PermissionsGuard implements CanActivate {
  private readonly logger = new Logger(PermissionsGuard.name);

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredPermissions || requiredPermissions.length === 0) {
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

    if (employee?.roles?.includes(ROLES.OWNER)) {
      return true;
    }

    if (!employee?.permissions?.length) {
      this.logger.warn(
        `Forbidden access: employee ${employee?.employeeId ?? 'unknown'} has no permissions`,
      );
      throw new ForbiddenException('Insufficient permissions');
    }

    const hasAllPermissions = requiredPermissions.every((permission) =>
      employee.permissions.includes(permission),
    );

    if (!hasAllPermissions) {
      this.logger.warn(
        `Forbidden access: employee ${employee.employeeId} missing permissions [${requiredPermissions.join(', ')}]`,
      );
      throw new ForbiddenException('Insufficient permissions');
    }

    return true;
  }
}
