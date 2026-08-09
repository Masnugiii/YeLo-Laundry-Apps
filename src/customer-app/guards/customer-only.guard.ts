import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { isAuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';

@Injectable()
export class CustomerOnlyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{ user: unknown }>();

    if (!isAuthenticatedCustomer(request.user)) {
      throw new ForbiddenException('Customer access only');
    }

    return true;
  }
}
