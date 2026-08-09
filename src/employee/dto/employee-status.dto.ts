import { EmployeeStatus } from '@prisma/client';

export enum EmployeeStatusDto {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  RESIGNED = 'RESIGNED',
}

export function toPrismaEmployeeStatus(
  status: EmployeeStatusDto,
): EmployeeStatus {
  return status.toLowerCase() as EmployeeStatus;
}

export function toEmployeeStatusDto(
  status: EmployeeStatus,
): EmployeeStatusDto {
  return status.toUpperCase() as EmployeeStatusDto;
}
