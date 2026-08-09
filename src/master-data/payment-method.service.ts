import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import {
  CreatePaymentMethodDto,
  UpdatePaymentMethodDto,
} from './master-data.dto';

@Injectable()
export class PaymentMethodService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async list(includeInactive = false) {
    return this.prisma.paymentMethod.findMany({
      where: {
        deletedAt: null,
        ...(includeInactive ? {} : { isActive: true }),
      },
      orderBy: { name: 'asc' },
    });
  }

  async getById(id: string) {
    const method = await this.prisma.paymentMethod.findFirst({
      where: { id, deletedAt: null },
    });

    if (!method) {
      throw new NotFoundException('Payment method not found');
    }

    return method;
  }

  async create(dto: CreatePaymentMethodDto, employeeId: string) {
    const existing = await this.prisma.paymentMethod.findFirst({
      where: { code: dto.code, deletedAt: null },
      select: { id: true },
    });

    if (existing) {
      throw new ConflictException('Payment method code already exists');
    }

    const method = await this.prisma.paymentMethod.create({
      data: {
        code: dto.code,
        name: dto.name,
        isActive: dto.isActive ?? true,
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'payment_methods',
      action: 'payment_method_created',
      referenceId: method.id,
      after: method,
    });

    return method;
  }

  async update(id: string, dto: UpdatePaymentMethodDto, employeeId: string) {
    const before = await this.getById(id);

    const method = await this.prisma.paymentMethod.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });

    await this.auditService.logChange({
      employeeId,
      module: 'payment_methods',
      action: 'payment_method_updated',
      referenceId: method.id,
      before,
      after: method,
    });

    return method;
  }
}
