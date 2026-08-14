import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import { CreatePerfumeDto, UpdatePerfumeDto } from './perfume.dto';

@Injectable()
export class PerfumeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async listActive() {
    return this.prisma.laundryPerfume.findMany({
      where: { deletedAt: null, isActive: true },
      orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
    });
  }

  async listAll() {
    return this.prisma.laundryPerfume.findMany({
      where: { deletedAt: null },
      orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
    });
  }

  async getById(id: string) {
    const perfume = await this.prisma.laundryPerfume.findFirst({
      where: { id, deletedAt: null },
    });

    if (!perfume) {
      throw new NotFoundException('Perfume not found');
    }

    return perfume;
  }

  async create(dto: CreatePerfumeDto, employeeId: string) {
    const created = await this.prisma.laundryPerfume.create({
      data: {
        code: dto.code.trim().toUpperCase(),
        name: dto.name.trim(),
        extraPrice: dto.extraPrice ?? 0,
        displayOrder: dto.displayOrder ?? 0,
        isActive: dto.isActive ?? true,
      },
    });

    await this.auditService.logConfigUpdated({
      employeeId,
      module: 'perfume',
      referenceId: created.id,
      before: null,
      after: created,
    });

    return created;
  }

  async update(id: string, dto: UpdatePerfumeDto, employeeId: string) {
    const before = await this.getById(id);

    const updated = await this.prisma.laundryPerfume.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name.trim() }),
        ...(dto.extraPrice !== undefined && { extraPrice: dto.extraPrice }),
        ...(dto.displayOrder !== undefined && {
          displayOrder: dto.displayOrder,
        }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });

    await this.auditService.logConfigUpdated({
      employeeId,
      module: 'perfume',
      referenceId: id,
      before,
      after: updated,
    });

    return updated;
  }

  async softDelete(id: string, employeeId: string) {
    const before = await this.getById(id);

    const updated = await this.prisma.laundryPerfume.update({
      where: { id },
      data: { deletedAt: new Date(), isActive: false },
    });

    await this.auditService.logConfigUpdated({
      employeeId,
      module: 'perfume',
      referenceId: id,
      before,
      after: updated,
    });

    return updated;
  }

  toCustomerResponse(
    perfumes: Array<{
      id: string;
      code: string;
      name: string;
      extraPrice: { toNumber?: () => number } | number;
    }>,
  ) {
    return perfumes.map((perfume) => ({
      id: perfume.id,
      code: perfume.code,
      name: perfume.name,
      extraPrice:
        typeof perfume.extraPrice === 'number'
          ? perfume.extraPrice
          : Number(perfume.extraPrice),
    }));
  }
}
