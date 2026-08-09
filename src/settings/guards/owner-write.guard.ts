import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { ROLES } from '../../auth/constants/roles.constant';
import { AuthenticatedEmployee } from '../../auth/interfaces/jwt-payload.interface';

/**
 * Restricts configuration writes to OWNER role only.
 * MANAGER and other roles are rejected even if they pass route-level role checks.
 */
@Injectable()
export class OwnerWriteGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context
      .switchToHttp()
      .getRequest<{ user?: AuthenticatedEmployee }>();
    const user = request.user;

    if (!user?.roles?.includes(ROLES.OWNER)) {
      throw new ForbiddenException(
        'Only owner can update system configuration',
      );
    }

    return true;
  }
}
