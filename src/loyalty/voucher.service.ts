import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { LoyaltyVoucherStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';

export interface CreateVoucherInput {
  code: string;
  name: string;
  discountType: 'PERCENTAGE' | 'FIXED';
  discountValue: number;
  cashbackType?: 'PERCENTAGE' | 'FIXED';
  cashbackValue?: number;
  cashbackMax?: number;
  cashbackExpirationDays?: number;
  startDate: Date;
  endDate: Date;
  usageLimit?: number;
  minimumTransaction?: number;
  status?: LoyaltyVoucherStatus;
}

@Injectable()
export class VoucherService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: {
    page?: number;
    limit?: number;
    status?: LoyaltyVoucherStatus;
    search?: string;
  }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 25;
    const where = {
      deletedAt: null,
      ...(query.status ? { status: query.status } : {}),
      ...(query.search
        ? {
            OR: [
              { code: { contains: query.search, mode: 'insensitive' as const } },
              { name: { contains: query.search, mode: 'insensitive' as const } },
            ],
          }
        : {}),
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.loyaltyVoucher.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.loyaltyVoucher.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toResponse(item)),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) || 1 },
    };
  }

  async findOne(id: string) {
    const voucher = await this.prisma.loyaltyVoucher.findFirst({
      where: { id, deletedAt: null },
    });
    if (!voucher) throw new NotFoundException('Voucher not found');
    return this.toResponse(voucher);
  }

  async create(input: CreateVoucherInput) {
    const existing = await this.prisma.loyaltyVoucher.findFirst({
      where: { code: input.code.toUpperCase(), deletedAt: null },
    });
    if (existing) {
      throw new BadRequestException('Voucher code already exists');
    }

    const voucher = await this.prisma.loyaltyVoucher.create({
      data: {
        code: input.code.toUpperCase(),
        name: input.name,
        discountType: input.discountType,
        discountValue: input.discountValue,
        cashbackType: input.cashbackType,
        cashbackValue: input.cashbackValue,
        cashbackMax: input.cashbackMax,
        cashbackExpirationDays: input.cashbackExpirationDays,
        startDate: input.startDate,
        endDate: input.endDate,
        usageLimit: input.usageLimit ?? 0,
        minimumTransaction: input.minimumTransaction ?? 0,
        status: input.status ?? LoyaltyVoucherStatus.ACTIVE,
      },
    });

    return this.toResponse(voucher);
  }

  async incrementUsage(code: string) {
    const voucher = await this.prisma.loyaltyVoucher.findFirst({
      where: { code: code.toUpperCase(), deletedAt: null },
    });
    if (!voucher) return null;

    return this.prisma.loyaltyVoucher.update({
      where: { id: voucher.id },
      data: { usageCount: { increment: 1 } },
    });
  }

  private toResponse(voucher: {
    id: string;
    code: string;
    name: string;
    discountType: string;
    discountValue: { toString(): string };
    cashbackType: string | null;
    cashbackValue: { toString(): string } | null;
    cashbackMax: { toString(): string } | null;
    cashbackExpirationDays: number | null;
    startDate: Date;
    endDate: Date;
    usageLimit: number;
    usageCount: number;
    minimumTransaction: { toString(): string };
    status: string;
    createdAt: Date;
    updatedAt: Date;
  }) {
    return {
      id: voucher.id,
      code: voucher.code,
      name: voucher.name,
      discountType: voucher.discountType,
      discountValue: Number(voucher.discountValue),
      cashbackType: voucher.cashbackType,
      cashbackValue: voucher.cashbackValue ? Number(voucher.cashbackValue) : null,
      cashbackMax: voucher.cashbackMax ? Number(voucher.cashbackMax) : null,
      cashbackExpirationDays: voucher.cashbackExpirationDays,
      startDate: voucher.startDate,
      endDate: voucher.endDate,
      usageLimit: voucher.usageLimit,
      usageCount: voucher.usageCount,
      minimumTransaction: Number(voucher.minimumTransaction),
      status: voucher.status,
      createdAt: voucher.createdAt,
      updatedAt: voucher.updatedAt,
    };
  }
}
