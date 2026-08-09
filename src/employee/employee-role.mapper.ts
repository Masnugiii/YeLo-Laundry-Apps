import { Role, RoleCode } from '@prisma/client';
import { mapRoleCode } from '../auth/utils/role.util';
import { EmployeeRoleResponseDto } from './dto/employee-role-response.dto';

export function toEmployeeRoleResponse(role: Role): EmployeeRoleResponseDto {
  return {
    id: role.id,
    code: mapRoleCode(role.code as RoleCode),
    name: role.name,
  };
}
