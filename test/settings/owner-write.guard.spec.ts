import { ForbiddenException } from '@nestjs/common';
import { ExecutionContext } from '@nestjs/common/interfaces';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { OwnerWriteGuard } from '../../src/settings/guards/owner-write.guard';

describe('OwnerWriteGuard', () => {
  const guard = new OwnerWriteGuard();

  function createContext(roles: string[]): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            employeeId: 'emp-1',
            roles,
            permissions: [],
          },
        }),
      }),
    } as ExecutionContext;
  }

  it('allows OWNER to update configuration', () => {
    expect(guard.canActivate(createContext([ROLES.OWNER]))).toBe(true);
  });

  it('rejects MANAGER with 403', () => {
    expect(() => guard.canActivate(createContext([ROLES.MANAGER]))).toThrow(
      ForbiddenException,
    );
  });

  it('rejects users without OWNER role', () => {
    expect(() => guard.canActivate(createContext([ROLES.CASHIER]))).toThrow(
      ForbiddenException,
    );
  });
});
