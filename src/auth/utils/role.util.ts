import { RoleCode } from '@prisma/client';
import { Role, ROLES } from '../constants/roles.constant';

const ROLE_CODE_MAP: Record<RoleCode, Role> = {
  [RoleCode.owner]: ROLES.OWNER,
  [RoleCode.cashier]: ROLES.CASHIER,
  [RoleCode.cashier_laundry]: ROLES.OPERATOR,
  [RoleCode.cashier_laundry_driver]: ROLES.MANAGER,
  [RoleCode.laundry]: ROLES.BINATU,
  [RoleCode.driver]: ROLES.DRIVER,
};

export function mapRoleCode(code: RoleCode): Role {
  return ROLE_CODE_MAP[code];
}

const ROLE_TO_CODE_MAP: Record<Role, RoleCode> = {
  [ROLES.OWNER]: RoleCode.owner,
  [ROLES.CASHIER]: RoleCode.cashier,
  [ROLES.OPERATOR]: RoleCode.cashier_laundry,
  [ROLES.MANAGER]: RoleCode.cashier_laundry_driver,
  [ROLES.BINATU]: RoleCode.laundry,
  [ROLES.DRIVER]: RoleCode.driver,
};

export function mapRoleToCode(role: Role): RoleCode {
  return ROLE_TO_CODE_MAP[role];
}

export function extractRoles(
  employeeRoles: Array<{ role: { code: RoleCode } }>,
): Role[] {
  return employeeRoles.map((employeeRole) => mapRoleCode(employeeRole.role.code));
}

export function extractPermissions(
  employeeRoles: Array<{
    role: {
      rolePermissions: Array<{
        permission: { code: string; isActive: boolean };
      }>;
    };
  }>,
): string[] {
  const permissions = new Set<string>();

  for (const employeeRole of employeeRoles) {
    for (const rolePermission of employeeRole.role.rolePermissions) {
      if (rolePermission.permission.isActive) {
        permissions.add(rolePermission.permission.code);
      }
    }
  }

  return Array.from(permissions);
}
