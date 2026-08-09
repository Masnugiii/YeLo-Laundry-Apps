export const EMPLOYEE_ROLES = [
  "OWNER",
  "MANAGER",
  "CASHIER",
  "OPERATOR",
  "BINATU",
  "DRIVER",
] as const;

export type EmployeeRole = (typeof EMPLOYEE_ROLES)[number];

export const EMPLOYEE_STATUSES = [
  "ACTIVE",
  "INACTIVE",
  "SUSPENDED",
  "RESIGNED",
] as const;

export type EmployeeStatus = (typeof EMPLOYEE_STATUSES)[number];

export interface Employee {
  id: string;
  employeeCode: string;
  fullName: string;
  phone: string;
  email: string | null;
  position: string;
  status: EmployeeStatus;
  roles: string[];
  hiredAt: string | null;
  lastLoginAt: string | null;
  createdAt: string;
  updatedAt: string;
  deletedAt: string | null;
}

export interface EmployeeListParams {
  page?: number;
  limit?: number;
  search?: string;
  role?: EmployeeRole;
  status?: EmployeeStatus;
  sortBy?: "createdAt" | "updatedAt" | "fullName" | "employeeCode";
  sortOrder?: "asc" | "desc";
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

export interface UpdateEmployeeInput {
  employeeCode?: string;
  fullName?: string;
  phone?: string;
  email?: string;
  position?: string;
  status?: EmployeeStatus;
}

export interface ResetEmployeePasswordInput {
  newPassword: string;
}

export interface CreateEmployeeInput {
  employeeCode: string;
  fullName: string;
  phone: string;
  email?: string;
  password: string;
  status: EmployeeStatus;
  position?: string;
}
