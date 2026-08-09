import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AssignPermissionsDto } from './dto/assign-permissions.dto';
import { PermissionQueryDto } from './dto/permission-query.dto';
import { PermissionResponseDto } from './dto/permission-response.dto';
import { toPermissionResponse } from './permission.mapper';
import { PermissionRepository } from './permission.repository';

@Injectable()
export class PermissionService {
  private readonly logger = new Logger(PermissionService.name);

  constructor(private readonly permissionRepository: PermissionRepository) {}

  async findAll(
    query: PermissionQueryDto,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    const permissions = await this.permissionRepository.findAll(query);

    return {
      success: true,
      message: 'Permissions retrieved successfully',
      data: permissions.map(toPermissionResponse),
    };
  }

  async getRolePermissions(
    roleId: string,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    await this.ensureRoleExists(roleId);

    const assignments =
      await this.permissionRepository.findPermissionsByRoleId(roleId);

    return {
      success: true,
      message: 'Role permissions retrieved successfully',
      data: assignments.map((assignment) =>
        toPermissionResponse(assignment.permission),
      ),
    };
  }

  async assignPermissions(
    roleId: string,
    dto: AssignPermissionsDto,
  ): Promise<ApiSuccessResponse<PermissionResponseDto[]>> {
    await this.ensureRoleExists(roleId);

    const uniquePermissionIds = this.ensureUniquePermissionIds(dto.permissionIds);

    if (uniquePermissionIds.length > 0) {
      await this.validatePermissions(uniquePermissionIds);
    }

    const assignments = await this.permissionRepository.replaceRolePermissions(
      roleId,
      uniquePermissionIds,
    );

    this.logger.log(
      `Permissions assigned to role ${roleId}: [${uniquePermissionIds.join(', ')}]`,
    );
    this.logger.log(`Permission updated for role ${roleId}`);

    return {
      success: true,
      message: 'Role permissions updated successfully',
      data: assignments.map((assignment) =>
        toPermissionResponse(assignment.permission),
      ),
    };
  }

  async removePermission(
    roleId: string,
    permissionId: string,
  ): Promise<ApiSuccessResponse<null>> {
    await this.ensureRoleExists(roleId);

    const assignment = await this.permissionRepository.findRolePermission(
      roleId,
      permissionId,
    );

    if (!assignment) {
      throw new NotFoundException('Permission assignment not found');
    }

    await this.permissionRepository.removeRolePermission(roleId, permissionId);

    this.logger.log(`Permission ${permissionId} removed from role ${roleId}`);
    this.logger.log(`Permission updated for role ${roleId}`);

    return {
      success: true,
      message: 'Permission removed successfully',
      data: null,
    };
  }

  private async ensureRoleExists(roleId: string): Promise<void> {
    const role = await this.permissionRepository.findRoleById(roleId);

    if (!role) {
      throw new NotFoundException('Role not found');
    }
  }

  private ensureUniquePermissionIds(permissionIds: string[]): string[] {
    const uniquePermissionIds = [...new Set(permissionIds)];

    if (uniquePermissionIds.length !== permissionIds.length) {
      throw new BadRequestException(
        'Duplicate permission assignments are not allowed',
      );
    }

    return uniquePermissionIds;
  }

  private async validatePermissions(permissionIds: string[]): Promise<void> {
    const permissions = await this.permissionRepository.findByIds(permissionIds);

    if (permissions.length !== permissionIds.length) {
      throw new NotFoundException('One or more permissions not found');
    }

    const inactivePermission = permissions.find(
      (permission) => !permission.isActive,
    );

    if (inactivePermission) {
      throw new BadRequestException(
        `Inactive permission cannot be assigned: ${inactivePermission.name}`,
      );
    }
  }
}
