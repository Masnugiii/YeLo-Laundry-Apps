import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { PERMISSIONS } from '../../src/auth/constants/permissions.constant';
import { PERMISSIONS_KEY } from '../../src/auth/decorators/permissions.decorator';
import { ROLES_KEY } from '../../src/auth/decorators/roles.decorator';
import { PermissionsGuard } from '../../src/auth/guards/permissions.guard';
import { RolesGuard } from '../../src/auth/guards/roles.guard';

describe('Payment mutation RBAC', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;

  const permissionsGuard = new PermissionsGuard(reflector);
  const rolesGuard = new RolesGuard(reflector);

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
        return [PERMISSIONS.FINANCE];
      }
      if (key === ROLES_KEY) {
        return undefined;
      }
      return undefined;
    });
  });

  it('allows OPERATOR with finance permission', () => {
    const user = {
      employeeId: 'operator-id',
      roles: [ROLES.OPERATOR],
      permissions: ['finance'],
    };

    expect(permissionsGuard.canActivate(createContext(user))).toBe(true);
    expect(rolesGuard.canActivate(createContext(user))).toBe(true);
  });

  it('allows CASHIER with finance permission', () => {
    const user = {
      employeeId: 'cashier-id',
      roles: [ROLES.CASHIER],
      permissions: ['finance'],
    };

    expect(permissionsGuard.canActivate(createContext(user))).toBe(true);
    expect(rolesGuard.canActivate(createContext(user))).toBe(true);
  });

  it('rejects OPERATOR without finance permission', () => {
    const user = {
      employeeId: 'operator-id',
      roles: [ROLES.OPERATOR],
      permissions: ['orders'],
    };

    expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
      ForbiddenException,
    );
  });

  it('rejects BINATU without finance permission', () => {
    const user = {
      employeeId: 'binatu-id',
      roles: [ROLES.BINATU],
      permissions: ['ironing'],
    };

    expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
      ForbiddenException,
    );
  });

  it('rejects DRIVER without finance permission', () => {
    const user = {
      employeeId: 'driver-id',
      roles: [ROLES.DRIVER],
      permissions: ['pickup', 'delivery'],
    };

    expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
      ForbiddenException,
    );
  });
});
