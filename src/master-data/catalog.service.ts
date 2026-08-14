import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import {
  CreateServiceDto,
  CreateServicePriceDto,
  ServiceQueryDto,
  UpdateServiceDto,
  UpdateServicePriceDto,
} from './catalog.dto';

@Injectable()
export class CatalogService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async listServices(query: ServiceQueryDto = {}) {
    const where: Prisma.ServiceWhereInput = {
      deletedAt: null,
      ...(query.includeInactive ? {} : { isActive: true }),
    };

    if (query.search?.trim()) {
      const keyword = query.search.trim();
      where.OR = [
        { serviceCode: { contains: keyword, mode: 'insensitive' } },
        { serviceName: { contains: keyword, mode: 'insensitive' } },
      ];
    }

    return this.prisma.service.findMany({
      where,
      include: {
        category: { select: { id: true, code: true, name: true } },
        prices: {
          where: { deletedAt: null, isActive: true },
          orderBy: { effectiveDate: 'desc' },
          take: 1,
        },
      },
      orderBy: { serviceName: 'asc' },
    });
  }

  async getService(id: string) {
    const service = await this.prisma.service.findFirst({
      where: { id, deletedAt: null },
      include: {
        category: { select: { id: true, code: true, name: true } },
        prices: {
          where: { deletedAt: null },
          orderBy: [{ isActive: 'desc' }, { effectiveDate: 'desc' }],
        },
      },
    });

    if (!service) {
      throw new NotFoundException('Service not found');
    }

    return service;
  }

  async createService(dto: CreateServiceDto, employeeId: string) {
    const existing = await this.prisma.service.findFirst({
      where: {
        serviceCode: dto.serviceCode,
        deletedAt: null,
      },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictException('Service code already exists');
    }

    const service = await this.prisma.service.create({
      data: {
        categoryId: dto.categoryId,
        serviceCode: dto.serviceCode,
        serviceName: dto.serviceName,
        description: dto.description,
        unitType: dto.unitType,
        weight: dto.weight ?? dto.unitType === 'kg',
        piece:
          dto.piece ??
          (dto.unitType === 'piece' || dto.unitType === 'item'),
        durationDay: dto.durationDay,
        isActive: dto.isActive ?? true,
      },
      include: {
        category: { select: { id: true, code: true, name: true } },
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_created',
      referenceId: service.id,
      after: service,
    });

    return service;
  }

  async updateService(id: string, dto: UpdateServiceDto, employeeId: string) {
    const before = await this.getService(id);

    if (dto.serviceCode && dto.serviceCode !== before.serviceCode) {
      const duplicate = await this.prisma.service.findFirst({
        where: {
          serviceCode: dto.serviceCode,
          deletedAt: null,
          id: { not: id },
        },
        select: { id: true },
      });

      if (duplicate) {
        throw new ConflictException('Service code already exists');
      }
    }

    const service = await this.prisma.service.update({
      where: { id },
      data: {
        ...(dto.categoryId !== undefined && { categoryId: dto.categoryId }),
        ...(dto.serviceCode !== undefined && { serviceCode: dto.serviceCode }),
        ...(dto.serviceName !== undefined && { serviceName: dto.serviceName }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.unitType !== undefined && { unitType: dto.unitType }),
        ...(dto.weight !== undefined && { weight: dto.weight }),
        ...(dto.piece !== undefined && { piece: dto.piece }),
        ...(dto.durationDay !== undefined && { durationDay: dto.durationDay }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
      include: {
        category: { select: { id: true, code: true, name: true } },
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_updated',
      referenceId: service.id,
      before,
      after: service,
    });

    return service;
  }

  async deleteService(id: string, employeeId: string) {
    const before = await this.getService(id);

    const service = await this.prisma.service.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_deleted',
      referenceId: service.id,
      before,
      after: service,
    });

    return service;
  }

  async listPrices(serviceId?: string) {
    return this.prisma.servicePrice.findMany({
      where: {
        deletedAt: null,
        ...(serviceId ? { serviceId } : {}),
      },
      include: {
        service: {
          select: {
            id: true,
            serviceCode: true,
            serviceName: true,
            isActive: true,
          },
        },
      },
      orderBy: [{ serviceId: 'asc' }, { effectiveDate: 'desc' }],
    });
  }

  async createPrice(dto: CreateServicePriceDto, employeeId: string) {
    // Allow pricing inactive services so Admin can set price before re-activating.
    const service = await this.prisma.service.findFirst({
      where: { id: dto.serviceId, deletedAt: null },
      select: { id: true },
    });

    if (!service) {
      throw new NotFoundException('Service not found');
    }

    if (dto.price < 0) {
      throw new BadRequestException('Service price cannot be negative');
    }

    const effectiveDate = dto.effectiveDate
      ? new Date(dto.effectiveDate)
      : new Date();
    effectiveDate.setHours(0, 0, 0, 0);

    const shouldActivate = dto.isActive ?? true;

    const price = await this.prisma.$transaction(async (tx) => {
      if (shouldActivate) {
        await tx.servicePrice.updateMany({
          where: {
            serviceId: dto.serviceId,
            isActive: true,
            deletedAt: null,
          },
          data: { isActive: false },
        });
      }

      // Upsert same-day price to avoid unique (serviceId, effectiveDate) conflicts.
      const existingSameDay = await tx.servicePrice.findFirst({
        where: {
          serviceId: dto.serviceId,
          effectiveDate,
          deletedAt: null,
        },
        select: { id: true },
      });

      if (existingSameDay) {
        return tx.servicePrice.update({
          where: { id: existingSameDay.id },
          data: {
            price: dto.price,
            isActive: shouldActivate,
            expiredDate: null,
          },
          include: {
            service: {
              select: { id: true, serviceCode: true, serviceName: true },
            },
          },
        });
      }

      return tx.servicePrice.create({
        data: {
          serviceId: dto.serviceId,
          price: dto.price,
          effectiveDate,
          isActive: shouldActivate,
        },
        include: {
          service: {
            select: { id: true, serviceCode: true, serviceName: true },
          },
        },
      });
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_price_created',
      referenceId: price.id,
      after: price,
    });

    return price;
  }

  async updatePrice(
    id: string,
    dto: UpdateServicePriceDto,
    employeeId: string,
  ) {
    const existing = await this.prisma.servicePrice.findFirst({
      where: { id, deletedAt: null },
      include: {
        service: {
          select: { id: true, serviceCode: true, serviceName: true },
        },
      },
    });

    if (!existing) {
      throw new NotFoundException('Service price not found');
    }

    const price = await this.prisma.$transaction(async (tx) => {
      if (dto.isActive === true) {
        await tx.servicePrice.updateMany({
          where: {
            serviceId: existing.serviceId,
            isActive: true,
            deletedAt: null,
            id: { not: id },
          },
          data: { isActive: false },
        });
      }

      if (dto.isActive === true) {
        const otherActive = await tx.servicePrice.count({
          where: {
            serviceId: existing.serviceId,
            isActive: true,
            deletedAt: null,
            id: { not: id },
          },
        });

        if (otherActive > 0) {
          throw new BadRequestException(
            'Only one active price is allowed per service',
          );
        }
      }

      return tx.servicePrice.update({
        where: { id },
        data: {
          ...(dto.price !== undefined && { price: dto.price }),
          ...(dto.effectiveDate !== undefined && {
            effectiveDate: new Date(dto.effectiveDate),
          }),
          ...(dto.expiredDate !== undefined && {
            expiredDate: dto.expiredDate ? new Date(dto.expiredDate) : null,
          }),
          ...(dto.isActive !== undefined && { isActive: dto.isActive }),
        },
        include: {
          service: {
            select: { id: true, serviceCode: true, serviceName: true },
          },
        },
      });
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_price_updated',
      referenceId: price.id,
      before: existing,
      after: price,
    });

    return price;
  }

  async deletePrice(id: string, employeeId: string) {
    const before = await this.prisma.servicePrice.findFirst({
      where: { id, deletedAt: null },
    });

    if (!before) {
      throw new NotFoundException('Service price not found');
    }

    const price = await this.prisma.servicePrice.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        isActive: false,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'catalog',
      action: 'service_price_deleted',
      referenceId: price.id,
      before,
      after: price,
    });

    return price;
  }
}
