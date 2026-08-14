import { Role } from '@prisma/client';
import { mapRoleCode } from '../auth/utils/role.util';
import { RoleResponseDto } from './dto/role-response.dto';

export function toRoleResponse(role: Role): RoleResponseDto {
  return {
    id: role.id,
    code: role.code,
    name: role.name,
    description: role.description,
    apiRole: mapRoleCode(role.code),
    isActive: role.isActive,
  };
}
