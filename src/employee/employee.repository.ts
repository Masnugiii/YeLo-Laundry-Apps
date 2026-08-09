import { Injectable } from '@nestjs/common';
import { EmployeeStatus, Prisma, RoleCode } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { employeeWithRolesInclude } from '../auth/auth.repository';
import { mapRoleToCode } from '../auth/utils/role.util';
import { EmployeeQueryDto, EmployeeSortField, SortOrder } from './dto/employee-query.dto';
import { toPrismaEmployeeStatus } from './dto/employee-status.dto';
import { employeeDetailSelect, employeeListSelect } from './employee.select';

@Injectable()
export class EmployeeRepository {
  constructor(private readonly prisma: PrismaService) {}

  findMany(query: EmployeeQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);
    const orderBy = this.buildOrderBy(query);

    return this.prisma.$transaction([
      this.prisma.employee.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        select: employeeListSelect,
      }),
      this.prisma.employee.count({ where }),
    ]);
  }

  findById(id: string, includeDeleted = false) {
    return this.prisma.employee.findFirst({
      where: {
        id,
        ...(includeDeleted ? {} : { deletedAt: null }),
      },
      select: employeeDetailSelect,
    });
  }

  findByIdWithRoles(id: string, includeDeleted = false) {
    return this.prisma.employee.findFirst({
      where: {
        id,
        ...(includeDeleted ? {} : { deletedAt: null }),
      },
      include: employeeWithRolesInclude,
    });
  }

  findCredentialsById(id: string) {
    return this.prisma.employee.findFirst({
      where: {
        id,
        deletedAt: null,
      },
      select: {
        id: true,
        passwordHash: true,
      },
    });
  }

  findByEmployeeCode(employeeCode: string, excludeId?: string) {
    return this.prisma.employee.findFirst({
      where: {
        employeeCode,
        deletedAt: null,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
      select: { id: true },
    });
  }

  findByPhone(phone: string, excludeId?: string) {
    return this.prisma.employee.findFirst({
      where: {
        phone,
        deletedAt: null,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
      select: { id: true },
    });
  }

  findByEmail(email: string, excludeId?: string) {
    return this.prisma.employee.findFirst({
      where: {
        email,
        deletedAt: null,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
      select: { id: true },
    });
  }

  hasRole(employeeId: string, roleCode: RoleCode) {
    return this.prisma.employeeRole.findFirst({
      where: {
        employeeId,
        deletedAt: null,
        role: { code: roleCode },
      },
      select: { id: true },
    });
  }

  countActiveEmployeesWithRole(roleCode: RoleCode, excludeEmployeeId?: string) {
    return this.prisma.employeeRole.count({
      where: {
        deletedAt: null,
        role: { code: roleCode },
        employee: {
          deletedAt: null,
          status: EmployeeStatus.active,
          ...(excludeEmployeeId ? { id: { not: excludeEmployeeId } } : {}),
        },
      },
    });
  }

  getStatistics() {
    const activeEmployeeWhere = {
      deletedAt: null,
      status: EmployeeStatus.active,
    } satisfies Prisma.EmployeeWhereInput;

    return this.prisma.$transaction([
      this.prisma.employee.count({ where: { deletedAt: null } }),
      this.prisma.employee.count({ where: activeEmployeeWhere }),
      this.prisma.employee.count({
        where: { deletedAt: null, status: EmployeeStatus.inactive },
      }),
      this.countEmployeesByRole(RoleCode.cashier_laundry_driver),
      this.countEmployeesByRole(RoleCode.cashier),
      this.countEmployeesByRole(RoleCode.cashier_laundry),
      this.countEmployeesByRole(RoleCode.driver),
      this.countEmployeesByRole(RoleCode.laundry),
    ]);
  }

  create(data: Prisma.EmployeeCreateInput) {
    return this.prisma.employee.create({
      data,
      select: employeeDetailSelect,
    });
  }

  update(id: string, data: Prisma.EmployeeUpdateInput) {
    return this.prisma.employee.update({
      where: { id },
      data,
      select: employeeDetailSelect,
    });
  }

  softDelete(id: string) {
    return this.prisma.employee.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: { id: true },
    });
  }

  restore(id: string) {
    return this.prisma.employee.update({
      where: { id },
      data: { deletedAt: null },
      select: employeeDetailSelect,
    });
  }

  private countEmployeesByRole(roleCode: RoleCode) {
    return this.prisma.employeeRole.count({
      where: {
        deletedAt: null,
        role: { code: roleCode },
        employee: {
          deletedAt: null,
          status: EmployeeStatus.active,
        },
      },
    });
  }

  private buildOrderBy(
    query: EmployeeQueryDto,
  ): Prisma.EmployeeOrderByWithRelationInput {
    const sortBy = query.sortBy ?? EmployeeSortField.CREATED_AT;
    const sortOrder = query.sortOrder ?? SortOrder.DESC;

    return { [sortBy]: sortOrder };
  }

  private buildWhereClause(query: EmployeeQueryDto): Prisma.EmployeeWhereInput {
    const where: Prisma.EmployeeWhereInput = {};

    if (query.deleted) {
      where.deletedAt = { not: null };
    } else {
      where.deletedAt = null;
    }

    if (query.status) {
      where.status = toPrismaEmployeeStatus(query.status);
    }

    if (query.role) {
      where.employeeRoles = {
        some: {
          deletedAt: null,
          role: {
            code: mapRoleToCode(query.role),
          },
        },
      };
    }

    const fieldFilters: Prisma.EmployeeWhereInput[] = [];

    if (query.employeeCode?.trim()) {
      fieldFilters.push({
        employeeCode: {
          contains: query.employeeCode.trim(),
          mode: 'insensitive',
        },
      });
    }

    if (query.fullName?.trim()) {
      fieldFilters.push({
        fullName: { contains: query.fullName.trim(), mode: 'insensitive' },
      });
    }

    if (query.phone?.trim()) {
      fieldFilters.push({
        phone: { contains: query.phone.trim(), mode: 'insensitive' },
      });
    }

    if (query.email?.trim()) {
      fieldFilters.push({
        email: { contains: query.email.trim(), mode: 'insensitive' },
      });
    }

    if (query.search?.trim()) {
      const keyword = query.search.trim();
      fieldFilters.push({
        OR: [
          { employeeCode: { contains: keyword, mode: 'insensitive' } },
          { fullName: { contains: keyword, mode: 'insensitive' } },
          { phone: { contains: keyword, mode: 'insensitive' } },
          { email: { contains: keyword, mode: 'insensitive' } },
        ],
      });
    }

    if (fieldFilters.length === 1) {
      Object.assign(where, fieldFilters[0]);
    } else if (fieldFilters.length > 1) {
      where.AND = fieldFilters;
    }

    return where;
  }
}
