import { Employee } from '@prisma/client';
import { extractPermissions, extractRoles } from '../auth/utils/role.util';
import { toEmployeeStatusDto } from './dto/employee-status.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';

type EmployeeWithRoles = Employee & {
  employeeRoles: Array<{
    role: {
      code: import('@prisma/client').RoleCode;
      rolePermissions: Array<{
        permission: { code: string; isActive: boolean };
      }>;
    };
  }>;
};

export function toProfileResponse(
  employee: EmployeeWithRoles,
): ProfileResponseDto {
  return {
    id: employee.id,
    employeeCode: employee.employeeCode,
    fullName: employee.fullName,
    phone: employee.phone,
    email: employee.email,
    avatar: employee.photoUrl,
    roles: extractRoles(employee.employeeRoles),
    permissions: extractPermissions(employee.employeeRoles),
    status: toEmployeeStatusDto(employee.status),
    createdAt: employee.createdAt,
    updatedAt: employee.updatedAt,
    lastLoginAt: employee.lastLoginAt,
  };
}
