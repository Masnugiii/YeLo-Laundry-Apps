import { ROLES } from '../../src/auth/constants/roles.constant';
import { RolesGuard } from '../../src/auth/guards/roles.guard';
import { Reflector } from '@nestjs/core';
import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { ROLES_KEY } from '../../src/auth/decorators/roles.decorator';

describe('Legacy configuration endpoint RBAC', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;

  const guard = new RolesGuard(reflector);

  function createContext(roles: string[]): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          user: {
            employeeId: 'emp-1',
            roles,
            permissions: ['settings', 'finance', 'loyalty'],
          },
        }),
      }),
      getHandler: () => ({}),
      getClass: () => ({}),
    } as ExecutionContext;
  }

  beforeEach(() => {
    jest.clearAllMocks();
    (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
      if (key === ROLES_KEY) {
        return [ROLES.OWNER];
      }
      return undefined;
    });
  });

  it('blocks MANAGER from legacy company settings PATCH', () => {
    expect(() =>
      guard.canActivate(createContext([ROLES.MANAGER])),
    ).toThrow(ForbiddenException);
  });

  it('blocks MANAGER from legacy payroll settings PATCH', () => {
    expect(() =>
      guard.canActivate(createContext([ROLES.MANAGER])),
    ).toThrow(ForbiddenException);
  });

  it('allows OWNER to legacy configuration PATCH endpoints', () => {
    expect(guard.canActivate(createContext([ROLES.OWNER]))).toBe(true);
  });
});
