import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';

export interface AuditLogItem {
  id: string;
  employeeId: string | null;
  employeeName: string | null;
  module: string;
  action: string;
  referenceId: string | null;
  description: string | null;
  createdAt: string;
}

export interface PaginatedAuditLogs {
  items: AuditLogItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

@Injectable()
export class AuditLogService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: {
    page?: number;
    limit?: number;
    module?: string;
    action?: string;
    search?: string;
  }): Promise<PaginatedAuditLogs> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: Prisma.AuditLogWhereInput = {};

    if (query.module) {
      where.module = query.module;
    }

    if (query.action) {
      where.action = query.action;
    }

    if (query.search) {
      where.OR = [
        { description: { contains: query.search, mode: 'insensitive' } },
        { module: { contains: query.search, mode: 'insensitive' } },
        { action: { contains: query.search, mode: 'insensitive' } },
      ];
    }

    const [records, total] = await this.prisma.$transaction([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          employee: {
            select: { fullName: true },
          },
        },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      items: records.map((record) => ({
        id: record.id,
        employeeId: record.employeeId,
        employeeName: record.employee?.fullName ?? null,
        module: record.module,
        action: record.action,
        referenceId: record.referenceId,
        description: record.description,
        createdAt: record.createdAt.toISOString(),
      })),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }
}
