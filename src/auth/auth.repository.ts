import { Injectable } from '@nestjs/common';
import { EmployeeStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';

export const employeeWithRolesInclude = {
  employeeRoles: {
    where: { deletedAt: null },
    include: {
      role: {
        include: {
          rolePermissions: {
            where: { deletedAt: null },
            include: {
              permission: true,
            },
          },
        },
      },
    },
  },
} as const;

@Injectable()
export class AuthRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findEmployeeByPhone(phone: string) {
    await this.prisma.ensureConnected();
    return this.prisma.employee.findFirst({
      where: {
        phone,
        deletedAt: null,
      },
      include: employeeWithRolesInclude,
    });
  }

  async findEmployeeById(id: string) {
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
