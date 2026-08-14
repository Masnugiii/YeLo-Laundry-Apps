import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { PERMISSIONS } from '../../src/auth/constants/permissions.constant';
import { PERMISSIONS_KEY } from '../../src/auth/decorators/permissions.decorator';
import { ROLES_KEY } from '../../src/auth/decorators/roles.decorator';
import { PermissionsGuard } from '../../src/auth/guards/permissions.guard';
import { RolesGuard } from '../../src/auth/guards/roles.guard';

const ORDER_COMPOSITION_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
] as const;

const PAYMENT_CONFIG_READ_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
] as const;

describe('Operational RBAC', () => {
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
  });

  describe('catalog read', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.ORDERS];
        }
        if (key === ROLES_KEY) {
          return [...ORDER_COMPOSITION_ROLES];
        }
        return undefined;
      });
    });

    it('allows CASHIER with orders permission to read catalog', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.ORDERS],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.ORDERS],
          }),
        ),
      ).toBe(true);
    });

    it('blocks DRIVER from catalog read', () => {
      expect(() =>
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'driver-id',
            roles: [ROLES.DRIVER],
            permissions: [PERMISSIONS.PICKUP, PERMISSIONS.DELIVERY],
          }),
        ),
      ).toThrow(ForbiddenException);

      expect(() =>
        rolesGuard.canActivate(
          createContext({
            employeeId: 'driver-id',
            roles: [ROLES.DRIVER],
            permissions: [PERMISSIONS.PICKUP, PERMISSIONS.DELIVERY],
          }),
        ),
      ).toThrow(ForbiddenException);
    });
  });

  describe('catalog mutation', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.SETTINGS];
        }
        if (key === ROLES_KEY) {
          return [ROLES.OWNER];
        }
        return undefined;
      });
    });

    it('blocks CASHIER from catalog mutation even with settings permission', () => {
      expect(() =>
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.SETTINGS, PERMISSIONS.ORDERS],
          }),
        ),
      ).toThrow(ForbiddenException);
    });
  });

  describe('company settings read', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.ORDERS];
        }
        if (key === ROLES_KEY) {
          return [...ORDER_COMPOSITION_ROLES];
        }
        return undefined;
      });
    });

    it('allows CASHIER to read company settings for order composition', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.ORDERS],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.ORDERS],
          }),
        ),
      ).toBe(true);
    });
  });

  describe('payment settings read', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.FINANCE];
        }
        if (key === ROLES_KEY) {
          return [...PAYMENT_CONFIG_READ_ROLES];
        }
        return undefined;
      });
    });

    it('allows CASHIER with finance permission to read payment config', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.FINANCE],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.FINANCE],
          }),
        ),
      ).toBe(true);
    });

    it('blocks OPERATOR without finance permission from payment config read', () => {
      expect(() =>
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'operator-id',
            roles: [ROLES.OPERATOR],
            permissions: [PERMISSIONS.ORDERS],
          }),
        ),
      ).toThrow(ForbiddenException);
    });
  });
});
