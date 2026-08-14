import { Injectable, Logger } from '@nestjs/common';
import { EmployeeStatus, Prisma } from '@prisma/client';
import {
  formatPrismaErrorForLog,
  PrismaService,
} from '../database/prisma/prisma.service';

export const employeeWithRolesInclude = {
  employeeRoles: {
    where: { deletedAt: null },
    include: {
      role: {
        include: {
          rolePermissions: {
            where: {
              deletedAt: null,
              permission: { deletedAt: null, isActive: true },
            },
            include: {
              permission: true,
            },
          },
        },
      },
    },
  },
} satisfies Prisma.EmployeeInclude;

export type EmployeeWithRoles = Prisma.EmployeeGetPayload<{
  include: typeof employeeWithRolesInclude;
}>;

@Injectable()
export class AuthRepository {
  private readonly logger = new Logger(AuthRepository.name);

  constructor(private readonly prisma: PrismaService) {}

  async findEmployeeByPhone(phone: string): Promise<EmployeeWithRoles | null> {
    await this.prisma.ensureConnected();
    this.logger.log('AuthRepository stage=employee_lookup_by_phone start');
    try {
      // Two-step lookup: identity first, then RBAC graph.
      // Keeps login usable even if nested include SQL fails (schema/pooler),
      // and surfaces the exact failing Prisma stage in logs.
      const identity = await this.prisma.employee.findFirst({
        where: {
          phone,
          deletedAt: null,
        },
        select: { id: true },
      });

      if (!identity) {
        this.logger.log(
          'AuthRepository stage=employee_lookup_by_phone end found=false',
        );
        return null;
      }

      const employee = await this.prisma.employee.findFirst({
        where: {
          id: identity.id,
          deletedAt: null,
        },
        include: employeeWithRolesInclude,
      });

      this.logger.log(
        `AuthRepository stage=employee_lookup_by_phone end found=${Boolean(
          employee,
        )} roleCount=${employee?.employeeRoles?.length ?? 0}`,
      );
      return employee;
    } catch (error: unknown) {
      this.logger.error(
        `AuthRepository stage=employee_lookup_by_phone failed ${formatPrismaErrorForLog(
          error,
        )}`,
      );
      throw error;
    }
  }

  async findEmployeeById(id: string): Promise<EmployeeWithRoles | null> {
    await this.prisma.ensureConnected();
    return this.prisma.employee.findFirst({
      where: {
        id,
        deletedAt: null,
        status: EmployeeStatus.active,
      },
      include: employeeWithRolesInclude,
    });
  }

  findSessionById(sessionId: string) {
    return this.prisma.employeeSession.findFirst({
      where: {
        id: sessionId,
        deletedAt: null,
      },
    });
  }

  updateSessionRefreshTokenHash(sessionId: string, refreshTokenHash: string) {
    return this.prisma.employeeSession.update({
      where: { id: sessionId },
      data: { refreshTokenHash },
    });
  }

  revokeAllSessionsForEmployee(employeeId: string) {
    return this.prisma.employeeSession.updateMany({
      where: {
        employeeId,
        revokedAt: null,
        deletedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });
  }
}
