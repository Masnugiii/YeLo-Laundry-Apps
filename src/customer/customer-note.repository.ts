import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerNoteQueryDto } from './dto/customer-note-query.dto';
import { customerNoteSelect } from './customer-note.select';
import {
  buildCategoryMarker,
  buildPinnedMarker,
} from './utils/customer-note-meta.util';

@Injectable()
export class CustomerNoteRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findMany(customerId: string, query: CustomerNoteQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const filter = this.buildFilter(customerId, query);

    const pinnedWhere: Prisma.CustomerNoteWhereInput = {
      AND: [filter, { note: { contains: buildPinnedMarker() } }],
    };

    const unpinnedWhere: Prisma.CustomerNoteWhereInput = {
      AND: [filter, { NOT: { note: { contains: buildPinnedMarker() } } }],
    };

    const [pinnedCount, unpinnedCount] = await this.prisma.$transaction([
      this.prisma.customerNote.count({ where: pinnedWhere }),
      this.prisma.customerNote.count({ where: unpinnedWhere }),
    ]);

    const total = pinnedCount + unpinnedCount;
    const items = [];

    if (skip < pinnedCount) {
      const pinnedTake = Math.min(limit, pinnedCount - skip);
      const pinned = await this.prisma.customerNote.findMany({
        where: pinnedWhere,
        skip,
        take: pinnedTake,
        orderBy: { createdAt: 'desc' },
        select: customerNoteSelect,
      });

      items.push(...pinned);

      const remaining = limit - pinned.length;

      if (remaining > 0) {
        const unpinned = await this.prisma.customerNote.findMany({
          where: unpinnedWhere,
          skip: 0,
          take: remaining,
          orderBy: { createdAt: 'desc' },
          select: customerNoteSelect,
        });

        items.push(...unpinned);
      }
    } else {
      const unpinned = await this.prisma.customerNote.findMany({
        where: unpinnedWhere,
        skip: skip - pinnedCount,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: customerNoteSelect,
      });

      items.push(...unpinned);
    }

    return [items, total] as const;
  }

  findById(customerId: string, noteId: string) {
    return this.prisma.customerNote.findFirst({
      where: { id: noteId, customerId, deletedAt: null },
      select: customerNoteSelect,
    });
  }

  create(customerId: string, employeeId: string, note: string) {
    return this.prisma.customerNote.create({
      data: {
        customerId,
        employeeId,
        note,
      },
      select: customerNoteSelect,
    });
  }

  update(noteId: string, note: string) {
    return this.prisma.customerNote.update({
      where: { id: noteId },
      data: { note },
      select: customerNoteSelect,
    });
  }

  softDelete(noteId: string) {
    return this.prisma.customerNote.update({
      where: { id: noteId },
      data: { deletedAt: new Date() },
      select: { id: true },
    });
  }

  private buildFilter(
    customerId: string,
    query: CustomerNoteQueryDto,
  ): Prisma.CustomerNoteWhereInput {
    const where: Prisma.CustomerNoteWhereInput = {
      customerId,
      deletedAt: null,
    };

    const filters: Prisma.CustomerNoteWhereInput[] = [];

    if (query.keyword?.trim()) {
      filters.push({
        note: { contains: query.keyword.trim(), mode: 'insensitive' },
      });
    }

    if (query.category) {
      filters.push({
        note: { contains: buildCategoryMarker(query.category) },
      });
    }

    if (filters.length === 1) {
      Object.assign(where, filters[0]);
    } else if (filters.length > 1) {
      where.AND = filters;
    }

    return where;
  }
}
