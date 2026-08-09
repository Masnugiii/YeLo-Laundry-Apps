import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';

@Injectable()
export class EmployeeRoleRepository {
  constructor(private readonly prisma: PrismaService) {}

  findRolesByEmployeeId(employeeId: string) {
    return this.prisma.employeeRole.findMany({
      where: {
        employeeId,
        deletedAt: null,
      },
      include: {
        role: true,
      },
      orderBy: {
        role: { name: 'asc' },
      },
    });
  }

  findRolesByIds(roleIds: string[]) {
    return this.prisma.role.findMany({
      where: {
        id: { in: roleIds },
        deletedAt: null,
      },
    });
  }

  findEmployeeRole(employeeId: string, roleId: string) {
    return this.prisma.employeeRole.findFirst({
      where: {
        employeeId,
        roleId,
        deletedAt: null,
      },
      include: {
        role: true,
      },
    });
  }

  replaceEmployeeRoles(
    employeeId: string,
    roleIds: string[],
    assignedByEmployeeId?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      await tx.employeeRole.updateMany({
        where: {
          employeeId,
          deletedAt: null,
        },
        data: {
          deletedAt: new Date(),
        },
      });

      for (const roleId of roleIds) {
        await tx.employeeRole.upsert({
          where: {
            employeeId_roleId: {
              employeeId,
              roleId,
            },
          },
          create: {
            employeeId,
            roleId,
            assignedByEmployeeId,
          },
          update: {
            deletedAt: null,
            assignedByEmployeeId,
            assignedAt: new Date(),
          },
        });
      }

      return tx.employeeRole.findMany({
        where: {
          employeeId,
          deletedAt: null,
        },
        include: {
          role: true,
        },
        orderBy: {
          role: { name: 'asc' },
        },
      });
    });
  }

  removeEmployeeRole(employeeId: string, roleId: string) {
    return this.prisma.employeeRole.updateMany({
      where: {
        employeeId,
        roleId,
        deletedAt: null,
      },
      data: {
        deletedAt: new Date(),
      },
    });
  }
}
