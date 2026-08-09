import { Employee, EmployeeStatus } from '@prisma/client';
import { extractRoles } from '../auth/utils/role.util';
import { toEmployeeStatusDto } from './dto/employee-status.dto';
import { EmployeeListRecord } from './employee.select';

export interface EmployeeResponse {
  id: string;
  employeeCode: string;
  fullName: string;
  phone: string;
  email: string | null;
  position: string;
  status: string;
  roles: string[];
  hiredAt: Date | null;
  lastLoginAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
}

export function toEmployeeResponse(
  employee: Employee | EmployeeListRecord,
): EmployeeResponse {
  const roles =
    'employeeRoles' in employee && employee.employeeRoles
      ? extractRoles(employee.employeeRoles)
      : [];

  return {
    id: employee.id,
    employeeCode: employee.employeeCode,
    fullName: employee.fullName,
    phone: employee.phone,
    email: employee.email,
    position: employee.position,
    status: toEmployeeStatusDto(employee.status),
    roles,
    hiredAt: employee.hiredAt,
    lastLoginAt: employee.lastLoginAt,
    createdAt: employee.createdAt,
    updatedAt: employee.updatedAt,
    deletedAt: employee.deletedAt,
  };
}

export interface PaginatedEmployees {
  items: EmployeeResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface EmployeeStatistics {
  totalEmployees: number;
  activeEmployees: number;
  inactiveEmployees: number;
  managers: number;
  cashiers: number;
  operators: number;
  drivers: number;
  binatu: number;
}

export function isEmployeeActive(employee: {
  status: EmployeeStatus;
  deletedAt: Date | null;
}): boolean {
  return employee.deletedAt === null && employee.status === EmployeeStatus.active;
}
