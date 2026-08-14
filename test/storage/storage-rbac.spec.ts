import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES } from '../../src/auth/constants/roles.constant';
import { PERMISSIONS } from '../../src/auth/constants/permissions.constant';
import { PERMISSIONS_KEY } from '../../src/auth/decorators/permissions.decorator';
import { ROLES_KEY } from '../../src/auth/decorators/roles.decorator';
import { PermissionsGuard } from '../../src/auth/guards/permissions.guard';
import { RolesGuard } from '../../src/auth/guards/roles.guard';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const WRITE_ROLES = [ROLES.MANAGER, ROLES.OPERATOR, ROLES.BINATU] as const;

describe('Storage RBAC', () => {
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

  describe('view endpoints', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.STORAGE];
        }
        if (key === ROLES_KEY) {
          return [...VIEW_ROLES];
        }
        return undefined;
      });
    });

    it('allows OWNER to read storage without storage permission in JWT', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'owner-id',
            roles: [ROLES.OWNER],
            permissions: [],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'owner-id',
            roles: [ROLES.OWNER],
            permissions: [],
          }),
        ),
      ).toBe(true);
    });

    it('allows CASHIER with storage permission to read storage', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toBe(true);
    });
  });

  describe('mutation endpoints', () => {
    beforeEach(() => {
      (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) => {
        if (key === PERMISSIONS_KEY) {
          return [PERMISSIONS.STORAGE];
        }
        if (key === ROLES_KEY) {
          return [...WRITE_ROLES];
        }
        return undefined;
      });
    });

    it('blocks OWNER from assign/move even though permissions guard passes', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'owner-id',
            roles: [ROLES.OWNER],
            permissions: [],
          }),
        ),
      ).toBe(true);

      expect(() =>
        rolesGuard.canActivate(
          createContext({
            employeeId: 'owner-id',
            roles: [ROLES.OWNER],
            permissions: [],
          }),
        ),
      ).toThrow(ForbiddenException);
    });

    it('allows MANAGER to mutate storage', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'manager-id',
            roles: [ROLES.MANAGER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toBe(true);

      expect(
        rolesGuard.canActivate(
          createContext({
            employeeId: 'manager-id',
            roles: [ROLES.MANAGER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toBe(true);
    });

    it('blocks CASHIER from assign/move', () => {
      expect(
        permissionsGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toBe(true);

      expect(() =>
        rolesGuard.canActivate(
          createContext({
            employeeId: 'cashier-id',
            roles: [ROLES.CASHIER],
            permissions: [PERMISSIONS.STORAGE],
          }),
        ),
      ).toThrow(ForbiddenException);
    });
  });
});
