import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, RewardCatalogType } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from '../master-data/audit/master-data-audit.service';
import { POINT_REWARD_VALUE_IDR } from './reward-catalog.constants';
import {
  CreateRewardCatalogItemDto,
  UpdateRewardCatalogItemDto,
} from './reward-catalog.dto';

@Injectable()
export class RewardCatalogAdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async list(includeInactive = true) {
    const items = await this.prisma.rewardCatalogItem.findMany({
      where: {
        deletedAt: null,
        ...(includeInactive ? {} : { isActive: true }),
      },
      orderBy: [{ costPoints: 'asc' }, { name: 'asc' }],
    });

    return items.map((item) => this.mapItem(item));
  }

  async getById(id: string) {
    const item = await this.prisma.rewardCatalogItem.findFirst({
      where: { id, deletedAt: null },
    });
    if (!item) {
      throw new NotFoundException('Reward catalog item not found');
    }
    return this.mapItem(item);
  }

  async create(dto: CreateRewardCatalogItemDto, employeeId: string) {
    this.validateCatalogInput(dto);

    const duplicate = await this.prisma.rewardCatalogItem.findFirst({
      where: { code: dto.code, deletedAt: null },
      select: { id: true },
    });
    if (duplicate) {
      throw new ConflictException('Reward code already exists');
    }

    const item = await this.prisma.rewardCatalogItem.create({
      data: {
        code: dto.code,
        name: dto.name,
        description: dto.description,
        type: dto.type,
        costPoints: dto.costPoints,
        isActive: dto.isActive ?? true,
        kg: dto.type === RewardCatalogType.LAUNDRY_KG ? dto.kg : null,
        serviceType:
          dto.type === RewardCatalogType.LAUNDRY_KG ? dto.serviceType : null,
        serviceDurationDays:
          dto.type === RewardCatalogType.LAUNDRY_KG
            ? dto.serviceDurationDays
            : null,
        stock:
          dto.type === RewardCatalogType.PHYSICAL_GOODS ? dto.stock : null,
        metadata: dto.metadata as Prisma.InputJsonValue | undefined,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'loyalty',
      action: 'reward_catalog_created',
      referenceId: item.id,
      after: item,
    });

    return this.mapItem(item);
  }

  async update(
    id: string,
    dto: UpdateRewardCatalogItemDto,
    employeeId: string,
  ) {
    const before = await this.getById(id);

    if (dto.code && dto.code !== before.code) {
      const duplicate = await this.prisma.rewardCatalogItem.findFirst({
        where: { code: dto.code, deletedAt: null, id: { not: id } },
        select: { id: true },
      });
      if (duplicate) {
        throw new ConflictException('Reward code already exists');
      }
    }

    const nextType = dto.type ?? before.type;
    this.validateCatalogInput({
      code: dto.code ?? before.code,
      name: dto.name ?? before.name,
      type: nextType,
      costPoints: dto.costPoints ?? before.costPoints,
      kg: dto.kg === undefined ? before.kg ?? undefined : dto.kg ?? undefined,
      serviceDurationDays:
        dto.serviceDurationDays === undefined
          ? before.serviceDurationDays ?? undefined
          : dto.serviceDurationDays ?? undefined,
      stock:
        dto.stock === undefined ? before.stock ?? undefined : dto.stock ?? undefined,
    });

    const item = await this.prisma.rewardCatalogItem.update({
      where: { id },
      data: {
        ...(dto.code !== undefined && { code: dto.code }),
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.type !== undefined && { type: dto.type }),
        ...(dto.costPoints !== undefined && { costPoints: dto.costPoints }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
        ...(dto.kg !== undefined && { kg: dto.kg }),
        ...(dto.serviceType !== undefined && { serviceType: dto.serviceType }),
        ...(dto.serviceDurationDays !== undefined && {
          serviceDurationDays: dto.serviceDurationDays,
        }),
        ...(dto.stock !== undefined && { stock: dto.stock }),
        ...(dto.metadata !== undefined && {
          metadata: dto.metadata as Prisma.InputJsonValue,
        }),
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'loyalty',
      action: 'reward_catalog_updated',
      referenceId: item.id,
      before,
      after: this.mapItem(item),
    });

    return this.mapItem(item);
  }

  async delete(id: string, employeeId: string) {
    const before = await this.getById(id);

    const item = await this.prisma.rewardCatalogItem.update({
      where: { id },
      data: { deletedAt: new Date(), isActive: false },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'loyalty',
      action: 'reward_catalog_deleted',
      referenceId: item.id,
      before,
      after: { id: item.id, deletedAt: item.deletedAt },
    });

    return { id: item.id, deleted: true };
  }

  private validateCatalogInput(input: {
    type: RewardCatalogType;
    costPoints: number;
    kg?: number | null;
    serviceDurationDays?: number | null;
    stock?: number | null;
    code?: string;
    name?: string;
  }): void {
    if (input.costPoints < 0) {
      throw new BadRequestException('Reward cost points cannot be negative');
    }

    if (input.type === RewardCatalogType.LAUNDRY_KG) {
      if (!input.kg || input.kg <= 0) {
        throw new BadRequestException('CKS free KG must be greater than zero');
      }
      if (!input.serviceDurationDays || input.serviceDurationDays <= 0) {
        throw new BadRequestException('CKS duration days must be greater than zero');
      }
    }

    if (
      input.type === RewardCatalogType.PHYSICAL_GOODS &&
      input.stock != null &&
      input.stock < 0
    ) {
      throw new BadRequestException('Physical reward stock cannot be negative');
    }
  }

  private mapItem(item: {
    id: string;
    code: string;
    name: string;
    description: string | null;
    type: RewardCatalogType;
    costPoints: number;
    isActive: boolean;
    kg: number | null;
    serviceType: string | null;
    serviceDurationDays: number | null;
    stock: number | null;
    metadata: Prisma.JsonValue;
    createdAt: Date;
    updatedAt: Date;
  }) {
    return {
      id: item.id,
      code: item.code,
      name: item.name,
      description: item.description,
      type: item.type,
      costPoints: item.costPoints,
      isActive: item.isActive,
      kg: item.kg,
      entitlementKg: item.kg,
      serviceType: item.serviceType,
      serviceDurationDays: item.serviceDurationDays,
      durationDays: item.serviceDurationDays,
      stock: item.stock,
      metadata: item.metadata,
      pointRewardValueIdr: POINT_REWARD_VALUE_IDR,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    };
  }
}
