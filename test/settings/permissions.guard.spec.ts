import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PermissionsGuard } from '../../src/auth/guards/permissions.guard';
import { PERMISSIONS } from '../../src/auth/constants/permissions.constant';
import { PERMISSIONS_KEY } from '../../src/auth/decorators/permissions.decorator';

describe('PermissionsGuard settings access', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;

  const guard = new PermissionsGuard(reflector);

  function createContext(user?: {
    employeeId: string;
    roles: string[];
    permissions: string[];
  }): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({ user }),
      }),
      getHandler: () => ({}),
      getClass: () => ({}),
    } as ExecutionContext;
  }

  beforeEach(() => {
    jest.clearAllMocks();
    (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
      if (key === PERMISSIONS_KEY) {
        return [PERMISSIONS.SETTINGS];
      }
      return undefined;
    });
  });

  it('allows MANAGER with settings permission to read configuration', () => {
    expect(
      guard.canActivate(
        createContext({
          employeeId: 'manager-id',
          roles: ['MANAGER'],
          permissions: ['settings'],
        }),
      ),
    ).toBe(true);
  });

  it('rejects unauthorized users without permissions', () => {
    expect(() =>
      guard.canActivate(
        createContext({
          employeeId: 'cashier-id',
          roles: ['CASHIER'],
          permissions: ['orders'],
        }),
      ),
    ).toThrow(ForbiddenException);
  });
});
