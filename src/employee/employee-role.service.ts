import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { EmployeeStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AssignEmployeeRolesDto } from './dto/assign-employee-roles.dto';
import { EmployeeRoleResponseDto } from './dto/employee-role-response.dto';
import { toEmployeeRoleResponse } from './employee-role.mapper';
import { EmployeeRoleRepository } from './employee-role.repository';
import { EmployeeRepository } from './employee.repository';

@Injectable()
export class EmployeeRoleService {
  private readonly logger = new Logger(EmployeeRoleService.name);

  constructor(
    private readonly employeeRepository: EmployeeRepository,
    private readonly employeeRoleRepository: EmployeeRoleRepository,
  ) {}

  async getEmployeeRoles(
    employeeId: string,
  ): Promise<ApiSuccessResponse<EmployeeRoleResponseDto[]>> {
    await this.ensureEmployeeExists(employeeId);

    const assignments =
      await this.employeeRoleRepository.findRolesByEmployeeId(employeeId);

    this.logger.log(`Role assignment viewed for employee ${employeeId}`);

    return {
      success: true,
      message: 'Employee roles retrieved successfully',
      data: assignments.map((assignment) =>
        toEmployeeRoleResponse(assignment.role),
      ),
    };
  }

  async assignRoles(
    employeeId: string,
    dto: AssignEmployeeRolesDto,
    assignedByEmployeeId: string,
  ): Promise<ApiSuccessResponse<EmployeeRoleResponseDto[]>> {
    const employee = await this.employeeRepository.findById(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    if (employee.status !== EmployeeStatus.active) {
      throw new BadRequestException(
        'Inactive employees cannot receive role assignments',
      );
    }

    const uniqueRoleIds = this.ensureUniqueRoleIds(dto.roleIds);

    if (uniqueRoleIds.length > 0) {
      await this.validateRoles(uniqueRoleIds);
    }

    const assignments = await this.employeeRoleRepository.replaceEmployeeRoles(
      employeeId,
      uniqueRoleIds,
      assignedByEmployeeId,
    );

    this.logger.log(
      `Roles assigned to employee ${employeeId}: [${uniqueRoleIds.join(', ')}]`,
    );
    this.logger.log(`Role updated for employee ${employeeId}`);

    return {
      success: true,
      message: 'Employee roles updated successfully',
      data: assignments.map((assignment) =>
        toEmployeeRoleResponse(assignment.role),
      ),
    };
  }

  async removeRole(
    employeeId: string,
    roleId: string,
  ): Promise<ApiSuccessResponse<null>> {
    await this.ensureEmployeeExists(employeeId);

    const assignment = await this.employeeRoleRepository.findEmployeeRole(
      employeeId,
      roleId,
    );

    if (!assignment) {
      throw new NotFoundException('Role assignment not found');
    }

    await this.employeeRoleRepository.removeEmployeeRole(employeeId, roleId);

    this.logger.log(`Role ${roleId} removed from employee ${employeeId}`);
    this.logger.log(`Role updated for employee ${employeeId}`);

    return {
      success: true,
      message: 'Role removed successfully',
      data: null,
    };
  }

  private async ensureEmployeeExists(employeeId: string): Promise<void> {
    const employee = await this.employeeRepository.findById(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }
  }

  private ensureUniqueRoleIds(roleIds: string[]): string[] {
    const uniqueRoleIds = [...new Set(roleIds)];

    if (uniqueRoleIds.length !== roleIds.length) {
      throw new BadRequestException('Duplicate role assignments are not allowed');
    }

    return uniqueRoleIds;
  }

  private async validateRoles(roleIds: string[]): Promise<void> {
    const roles = await this.employeeRoleRepository.findRolesByIds(roleIds);

    if (roles.length !== roleIds.length) {
      throw new NotFoundException('One or more roles not found');
    }

    const inactiveRole = roles.find((role) => !role.isActive);

    if (inactiveRole) {
      throw new BadRequestException(
        `Inactive role cannot be assigned: ${inactiveRole.name}`,
      );
    }
  }
}
