import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { PERMISSIONS } from '../../src/auth/constants/permissions.constant';
import { PERMISSIONS_KEY } from '../../src/auth/decorators/permissions.decorator';
import { PermissionsGuard } from '../../src/auth/guards/permissions.guard';

describe('Customer wallet RBAC', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;

  const permissionsGuard = new PermissionsGuard(reflector);

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
  });

  describe('wallet view', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.WALLET];
        }
        return undefined;
      });
    });

    it('allows MANAGER with wallet permission', () => {
      const user = {
        employeeId: 'manager-id',
        roles: [ROLES.MANAGER],
        permissions: ['wallet'],
      };

      expect(permissionsGuard.canActivate(createContext(user))).toBe(true);
    });

    it('rejects MANAGER without wallet permission', () => {
      const user = {
        employeeId: 'manager-id',
        roles: [ROLES.MANAGER],
        permissions: ['customers'],
      };

      expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
        ForbiddenException,
      );
    });

    it('rejects BINATU without wallet permission', () => {
      const user = {
        employeeId: 'binatu-id',
        roles: [ROLES.BINATU],
        permissions: ['ironing'],
      };

      expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
        ForbiddenException,
      );
    });
  });

  describe('wallet top up', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.WALLET_TOPUP];
        }
        return undefined;
      });
    });

    it('allows CASHIER with wallet_topup permission', () => {
      const user = {
        employeeId: 'cashier-id',
        roles: [ROLES.CASHIER],
        permissions: ['wallet', 'wallet_topup'],
      };

      expect(permissionsGuard.canActivate(createContext(user))).toBe(true);
    });

    it('rejects MANAGER with view-only wallet permission', () => {
      const user = {
        employeeId: 'manager-id',
        roles: [ROLES.MANAGER],
        permissions: ['wallet'],
      };

      expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
        ForbiddenException,
      );
    });
  });

  describe('wallet deduct', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.WALLET_DEDUCT];
        }
        return undefined;
      });
    });

    it('allows CASHIER with wallet_deduct permission', () => {
      const user = {
        employeeId: 'cashier-id',
        roles: [ROLES.CASHIER],
        permissions: ['wallet', 'wallet_deduct'],
      };

      expect(permissionsGuard.canActivate(createContext(user))).toBe(true);
    });

    it('rejects MANAGER with view-only wallet permission', () => {
      const user = {
        employeeId: 'manager-id',
        roles: [ROLES.MANAGER],
        permissions: ['wallet'],
      };

      expect(() => permissionsGuard.canActivate(createContext(user))).toThrow(
        ForbiddenException,
      );
    });
  });
});
