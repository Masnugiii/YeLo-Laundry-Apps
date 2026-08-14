import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { RoleCode } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { normalizePhone } from '../auth/utils/phone.util';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { EmployeeQueryDto } from './dto/employee-query.dto';
import { EmployeeStatisticsDto } from './dto/employee-statistics.dto';
import { toPrismaEmployeeStatus } from './dto/employee-status.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import {
  EmployeeResponse,
  EmployeeStatistics,
  PaginatedEmployees,
  toEmployeeResponse,
} from './employee.mapper';
import { EmployeeRepository } from './employee.repository';

const BCRYPT_ROUNDS = 10;
const DEFAULT_POSITION = 'Staff';

@Injectable()
export class EmployeeService {
  private readonly logger = new Logger(EmployeeService.name);

  constructor(private readonly employeeRepository: EmployeeRepository) {}

  async findAll(
    query: EmployeeQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedEmployees>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [employees, total] = await this.employeeRepository.findMany(query);

    return {
      success: true,
      message: 'Employees retrieved successfully',
      data: {
        items: employees.map(toEmployeeResponse),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async getStatistics(): Promise<ApiSuccessResponse<EmployeeStatisticsDto>> {
    const [
      totalEmployees,
      activeEmployees,
      inactiveEmployees,
      managers,
      cashiers,
      operators,
      drivers,
      binatu,
    ] = await this.employeeRepository.getStatistics();

    const data: EmployeeStatistics = {
      totalEmployees,
      activeEmployees,
      inactiveEmployees,
      managers,
      cashiers,
      operators,
      drivers,
      binatu,
    };

    return {
      success: true,
      message: 'Employee statistics retrieved successfully',
      data,
    };
  }

  async findOne(id: string): Promise<ApiSuccessResponse<EmployeeResponse>> {
    const employee = await this.employeeRepository.findById(id);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    return {
      success: true,
      message: 'Employee retrieved successfully',
      data: toEmployeeResponse(employee),
    };
  }

  async create(
    dto: CreateEmployeeDto,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    const phone = normalizePhone(dto.phone);
    const email = dto.email?.trim().toLowerCase() ?? null;

    await this.ensureUniqueFields({
      employeeCode: dto.employeeCode,
      phone,
      email,
    });

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);

    const employee = await this.employeeRepository.create({
      employeeCode: dto.employeeCode,
      fullName: dto.fullName.trim(),
      phone,
      email,
      passwordHash,
      position: dto.position ?? DEFAULT_POSITION,
      status: toPrismaEmployeeStatus(dto.status),
    });

    this.logger.log(`Employee created: ${employee.id} (${employee.employeeCode})`);

    return {
      success: true,
      message: 'Employee created successfully',
      data: toEmployeeResponse(employee),
    };
  }

  async update(
    id: string,
    dto: UpdateEmployeeDto,
  ): Promise<ApiSuccessResponse<EmployeeResponse>> {
    const existing = await this.employeeRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Employee not found');
    }

    const phone = dto.phone ? normalizePhone(dto.phone) : undefined;
    const email =
      dto.email === undefined
        ? undefined
        : dto.email
          ? dto.email.trim().toLowerCase()
          : null;

    await this.ensureUniqueFields(
      {
        employeeCode: dto.employeeCode,
        phone,
        email: email ?? undefined,
      },
      id,
    );

    const employee = await this.employeeRepository.update(id, {
      ...(dto.employeeCode !== undefined && { employeeCode: dto.employeeCode }),
      ...(dto.fullName !== undefined && { fullName: dto.fullName.trim() }),
      ...(phone !== undefined && { phone }),
      ...(dto.email !== undefined && { email }),
      ...(dto.position !== undefined && { position: dto.position }),
      ...(dto.status !== undefined && {
        status: toPrismaEmployeeStatus(dto.status),
      }),
      ...(dto.password !== undefined && {
        passwordHash: await bcrypt.hash(dto.password, BCRYPT_ROUNDS),
      }),
    });

    this.logger.log(`Employee updated: ${employee.id} (${employee.employeeCode})`);

    return {
      success: true,
      message: 'Employee updated successfully',
      data: toEmployeeResponse(employee),
    };
  }

  async remove(
    id: string,
    currentEmployeeId: string,
  ): Promise<ApiSuccessResponse<null>> {
    if (id === currentEmployeeId) {
      throw new BadRequestException('You cannot delete your own account');
    }

    const existing = await this.employeeRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Employee not found');
    }

    const isOwner = await this.employeeRepository.hasRole(id, RoleCode.owner);

    if (isOwner) {
      const remainingOwners =
        await this.employeeRepository.countActiveEmployeesWithRole(
          RoleCode.owner,
          id,
        );

      if (remainingOwners === 0) {
        throw new BadRequestException(
          'Cannot delete the last active owner account',
        );
      }
    }

    await this.employeeRepository.softDelete(id);

    this.logger.log(
      `Employee soft deleted: ${existing.id} (${existing.employeeCode})`,
    );

    return {
      success: true,
      message: 'Employee deleted successfully',
      data: null,
    };
  }

  async restore(id: string): Promise<ApiSuccessResponse<EmployeeResponse>> {
    const existing = await this.employeeRepository.findById(id, true);

    if (!existing) {
      throw new NotFoundException('Employee not found');
    }

    if (!existing.deletedAt) {
      throw new BadRequestException('Employee is not deleted');
    }

    await this.ensureUniqueFields(
      {
        employeeCode: existing.employeeCode,
        phone: existing.phone,
        email: existing.email ?? undefined,
      },
      id,
    );

    const employee = await this.employeeRepository.restore(id);

    this.logger.log(`Employee restored: ${employee.id} (${employee.employeeCode})`);

    return {
      success: true,
      message: 'Employee restored successfully',
      data: toEmployeeResponse(employee),
    };
  }

  private async ensureUniqueFields(
    fields: {
      employeeCode?: string;
      phone?: string;
      email?: string | null;
    },
    excludeId?: string,
  ): Promise<void> {
    if (fields.employeeCode) {
      const existing = await this.employeeRepository.findByEmployeeCode(
        fields.employeeCode,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Employee code already exists');
      }
    }

    if (fields.phone) {
      const existing = await this.employeeRepository.findByPhone(
        fields.phone,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Phone number already exists');
      }
    }

    if (fields.email) {
      const existing = await this.employeeRepository.findByEmail(
        fields.email,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Email already exists');
      }
    }
  }
}
