import { Role } from '../constants/roles.constant';

export interface EmployeeJwtPayload {
  actorType?: 'employee';
  employeeId: string;
  phone: string;
  roles: Role[];
  permissions?: string[];
}

export interface CustomerJwtPayload {
  actorType: 'customer';
  customerId: string;
  phone: string;
  tokenType?: 'access' | 'refresh';
}

export type JwtPayload = EmployeeJwtPayload | CustomerJwtPayload;

export interface AuthenticatedEmployee {
  actorType?: 'employee';
  employeeId: string;
  phone: string;
  roles: Role[];
  permissions: string[];
}
