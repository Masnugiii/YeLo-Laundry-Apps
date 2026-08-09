import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { PermissionQueryDto } from './dto/permission-query.dto';

@Injectable()
export class PermissionRepository {
  constructor(private readonly prisma: PrismaService) {}

  findAll(query: PermissionQueryDto) {
    return this.prisma.permission.findMany({
      where: this.buildWhereClause(query),
      orderBy: [{ module: 'asc' }, { code: 'asc' }],
    });
  }

  findByIds(permissionIds: string[]) {
    return this.prisma.permission.findMany({
      where: {
        id: { in: permissionIds },
        deletedAt: null,
      },
    });
  }

  findRoleById(roleId: string) {
    return this.prisma.role.findFirst({
      where: {
        id: roleId,
        deletedAt: null,
      },
    });
  }

  findPermissionsByRoleId(roleId: string) {
    return this.prisma.rolePermission.findMany({
      where: {
        roleId,
        deletedAt: null,
      },
      include: {
        permission: true,
      },
      orderBy: {
        permission: { module: 'asc' },
      },
    });
  }

  findRolePermission(roleId: string, permissionId: string) {
    return this.prisma.rolePermission.findFirst({
      where: {
        roleId,
        permissionId,
        deletedAt: null,
      },
      include: {
        permission: true,
      },
    });
  }

  replaceRolePermissions(roleId: string, permissionIds: string[]) {
    return this.prisma.$transaction(async (tx) => {
      await tx.rolePermission.updateMany({
        where: {
          roleId,
          deletedAt: null,
        },
        data: {
          deletedAt: new Date(),
        },
      });

      for (const permissionId of permissionIds) {
        await tx.rolePermission.upsert({
          where: {
            roleId_permissionId: {
              roleId,
              permissionId,
            },
          },
          create: {
            roleId,
            permissionId,
          },
          update: {
            deletedAt: null,
          },
        });
      }

      return tx.rolePermission.findMany({
        where: {
          roleId,
          deletedAt: null,
        },
        include: {
          permission: true,
        },
        orderBy: {
          permission: { module: 'asc' },
        },
      });
    });
  }

  removeRolePermission(roleId: string, permissionId: string) {
    return this.prisma.rolePermission.updateMany({
      where: {
        roleId,
        permissionId,
        deletedAt: null,
      },
      data: {
        deletedAt: new Date(),
      },
    });
  }

  private buildWhereClause(
    query: PermissionQueryDto,
  ): Prisma.PermissionWhereInput {
    const where: Prisma.PermissionWhereInput = {
      deletedAt: null,
    };

    if (query.module?.trim()) {
      where.module = {
        equals: query.module.trim(),
        mode: 'insensitive',
      };
    }

    if (query.keyword?.trim()) {
      const keyword = query.keyword.trim();
      where.OR = [
        { code: { contains: keyword, mode: 'insensitive' } },
        { name: { contains: keyword, mode: 'insensitive' } },
        { module: { contains: keyword, mode: 'insensitive' } },
        { description: { contains: keyword, mode: 'insensitive' } },
      ];
    }

    return where;
  }
}
