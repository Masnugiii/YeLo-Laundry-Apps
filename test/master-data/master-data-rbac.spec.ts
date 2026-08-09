import { ForbiddenException } from '@nestjs/common';
import { ExecutionContext } from '@nestjs/common/interfaces';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { OwnerWriteGuard } from '../../src/settings/guards/owner-write.guard';

describe('Master data write RBAC', () => {
  const guard = new OwnerWriteGuard();

  function createContext(roles: string[]): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          user: { employeeId: 'emp-1', roles, permissions: ['settings'] },
        }),
      }),
    } as ExecutionContext;
  }

  it('blocks MANAGER from payment method writes', () => {
    expect(() => guard.canActivate(createContext([ROLES.MANAGER]))).toThrow(
      ForbiddenException,
    );
  });

  it('blocks MANAGER from expense category writes', () => {
    expect(() => guard.canActivate(createContext([ROLES.MANAGER]))).toThrow(
      ForbiddenException,
    );
  });
});
