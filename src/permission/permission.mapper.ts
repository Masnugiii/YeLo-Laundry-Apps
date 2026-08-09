import { Permission } from '@prisma/client';
import { PermissionResponseDto } from './dto/permission-response.dto';

export function toPermissionResponse(
  permission: Permission,
): PermissionResponseDto {
  return {
    id: permission.id,
    code: permission.code,
    name: permission.name,
    module: permission.module,
    description: permission.description,
  };
}
