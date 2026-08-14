import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { LoyaltyVoucherStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  CustomerPromoItem,
  CustomerPromoQuote,
} from './types/customer-promo.types';

export interface CreateVoucherInput {
  code: string;
  name: string;
  description?: string;
  discountType: 'PERCENTAGE' | 'FIXED';
  discountValue: number;
  maxDiscount?: number;
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

export interface UpdateVoucherInput {
  code?: string;
  name?: string;
  description?: string | null;
  discountType?: 'PERCENTAGE' | 'FIXED';
  discountValue?: number;
  maxDiscount?: number | null;
  cashbackType?: 'PERCENTAGE' | 'FIXED' | null;
  cashbackValue?: number | null;
  cashbackMax?: number | null;
  cashbackExpirationDays?: number | null;
  startDate?: Date;
  endDate?: Date;
  usageLimit?: number;
  minimumTransaction?: number;
  status?: LoyaltyVoucherStatus;
}

type VoucherRecord = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  discountType: string;
  discountValue: { toString(): string };
  maxDiscount: { toString(): string } | null;
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
};

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

  async findActiveForCustomer(query: { page?: number; limit?: number }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 25;
    const now = new Date();

    const where = {
      deletedAt: null,
      status: LoyaltyVoucherStatus.ACTIVE,
      startDate: { lte: now },
      endDate: { gte: now },
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.loyaltyVoucher.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ endDate: 'asc' }, { createdAt: 'desc' }],
      }),
      this.prisma.loyaltyVoucher.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toCustomerPromo(item)),
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) || 1 },
    };
  }

  async findCustomerPromoById(id: string): Promise<CustomerPromoItem> {
    const voucher = await this.prisma.loyaltyVoucher.findFirst({
      where: { id, deletedAt: null },
    });
    if (!voucher) throw new NotFoundException('Promo not found');
    return this.toCustomerPromo(voucher);
  }

  async quoteCustomerPromo(input: {
    promoId?: string;
    voucherCode?: string;
    subtotal: number;
  }): Promise<CustomerPromoQuote> {
    const voucher = await this.resolveVoucher(input.promoId, input.voucherCode);
    const usability = this.getUsability(voucher);

    if (!usability.isUsable) {
      throw new BadRequestException(
        usability.unusableReason ?? 'Promo is not available',
      );
    }

    if (input.subtotal < Number(voucher.minimumTransaction)) {
      throw new BadRequestException(
        `Minimum transaction is Rp${Number(voucher.minimumTransaction).toLocaleString('id-ID')}`,
      );
    }

    const discountAmount = this.calculateDiscountAmount(voucher, input.subtotal);

    return {
      promoId: voucher.id,
      voucherCode: voucher.code,
      subtotal: this.roundMoney(input.subtotal),
      discountPercent: this.getDiscountPercent(voucher),
      discountAmount,
      total: this.roundMoney(input.subtotal - discountAmount),
      maxDiscount: voucher.maxDiscount ? Number(voucher.maxDiscount) : null,
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

    this.validateDiscountInput(input.discountType, input.discountValue);

    const voucher = await this.prisma.loyaltyVoucher.create({
      data: {
        code: input.code.toUpperCase(),
        name: input.name,
        description: input.description?.trim() || null,
        discountType: input.discountType,
        discountValue: input.discountValue,
        maxDiscount: input.maxDiscount ?? null,
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

  async update(id: string, input: UpdateVoucherInput) {
    const existing = await this.prisma.loyaltyVoucher.findFirst({
      where: { id, deletedAt: null },
    });
    if (!existing) throw new NotFoundException('Voucher not found');

    if (input.code && input.code.toUpperCase() !== existing.code) {
      const duplicate = await this.prisma.loyaltyVoucher.findFirst({
        where: {
          code: input.code.toUpperCase(),
          deletedAt: null,
          NOT: { id },
        },
      });
      if (duplicate) {
        throw new BadRequestException('Voucher code already exists');
      }
    }

    const nextDiscountType = input.discountType ?? existing.discountType;
    const nextDiscountValue =
      input.discountValue !== undefined
        ? input.discountValue
        : Number(existing.discountValue);

    this.validateDiscountInput(nextDiscountType, nextDiscountValue);

    const voucher = await this.prisma.loyaltyVoucher.update({
      where: { id },
      data: {
        ...(input.code !== undefined
          ? { code: input.code.toUpperCase() }
          : {}),
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.description !== undefined
          ? { description: input.description?.trim() || null }
          : {}),
        ...(input.discountType !== undefined
          ? { discountType: input.discountType }
          : {}),
        ...(input.discountValue !== undefined
          ? { discountValue: input.discountValue }
          : {}),
        ...(input.maxDiscount !== undefined
          ? { maxDiscount: input.maxDiscount }
          : {}),
        ...(input.cashbackType !== undefined
          ? { cashbackType: input.cashbackType }
          : {}),
        ...(input.cashbackValue !== undefined
          ? { cashbackValue: input.cashbackValue }
          : {}),
        ...(input.cashbackMax !== undefined
          ? { cashbackMax: input.cashbackMax }
          : {}),
        ...(input.cashbackExpirationDays !== undefined
          ? { cashbackExpirationDays: input.cashbackExpirationDays }
          : {}),
        ...(input.startDate !== undefined ? { startDate: input.startDate } : {}),
        ...(input.endDate !== undefined ? { endDate: input.endDate } : {}),
        ...(input.usageLimit !== undefined ? { usageLimit: input.usageLimit } : {}),
        ...(input.minimumTransaction !== undefined
          ? { minimumTransaction: input.minimumTransaction }
          : {}),
        ...(input.status !== undefined ? { status: input.status } : {}),
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

  calculateDiscountAmount(voucher: VoucherRecord, subtotal: number): number {
    const discountValue = Number(voucher.discountValue);
    let amount = 0;

    if (voucher.discountType === 'PERCENTAGE') {
      amount = (subtotal * discountValue) / 100;
      const maxDiscount = voucher.maxDiscount
        ? Number(voucher.maxDiscount)
        : null;
      if (maxDiscount !== null && amount > maxDiscount) {
        amount = maxDiscount;
      }
    } else {
      amount = discountValue;
    }

    return this.roundMoney(Math.min(amount, subtotal));
  }

  private async resolveVoucher(promoId?: string, voucherCode?: string) {
    if (!promoId && !voucherCode) {
      throw new BadRequestException('Promo id or voucher code is required');
    }

    const voucher = await this.prisma.loyaltyVoucher.findFirst({
      where: {
        deletedAt: null,
        ...(promoId ? { id: promoId } : { code: voucherCode!.toUpperCase() }),
      },
    });

    if (!voucher) throw new NotFoundException('Promo not found');
    return voucher;
  }

  private getUsability(voucher: VoucherRecord) {
    const now = new Date();
    if (voucher.status !== LoyaltyVoucherStatus.ACTIVE) {
      return { isUsable: false, unusableReason: 'Promo tidak aktif' };
    }
    if (voucher.startDate > now) {
      return { isUsable: false, unusableReason: 'Promo belum dimulai' };
    }
    if (voucher.endDate < now) {
      return { isUsable: false, unusableReason: 'Promo sudah berakhir' };
    }
    if (
      voucher.usageLimit > 0 &&
      voucher.usageCount >= voucher.usageLimit
    ) {
      return { isUsable: false, unusableReason: 'Kuota promo habis' };
    }
    return { isUsable: true, unusableReason: null };
  }

  private getDiscountPercent(voucher: VoucherRecord): number | null {
    if (voucher.discountType !== 'PERCENTAGE') return null;
    return Number(voucher.discountValue);
  }

  private validateDiscountInput(
    discountType: 'PERCENTAGE' | 'FIXED',
    discountValue: number,
  ) {
    if (discountValue < 0) {
      throw new BadRequestException('Discount value cannot be negative');
    }
    if (discountType === 'PERCENTAGE' && discountValue > 100) {
      throw new BadRequestException(
        'Percentage discount cannot exceed 100',
      );
    }
  }

  private roundMoney(value: number) {
    return Number(value.toFixed(2));
  }

  private toCustomerPromo(voucher: VoucherRecord): CustomerPromoItem {
    const usability = this.getUsability(voucher);
    return {
      id: voucher.id,
      title: voucher.name,
      description: voucher.description ?? '',
      discountPercent: this.getDiscountPercent(voucher),
      discountType: voucher.discountType as 'PERCENTAGE' | 'FIXED',
      discountValue: Number(voucher.discountValue),
      voucherCode: voucher.code,
      minTransaction: Number(voucher.minimumTransaction),
      maxDiscount: voucher.maxDiscount ? Number(voucher.maxDiscount) : null,
      expiresAt: voucher.endDate.toISOString(),
      startsAt: voucher.startDate.toISOString(),
      isUsable: usability.isUsable,
      unusableReason: usability.unusableReason,
    };
  }

  private toResponse(voucher: VoucherRecord) {
    const discountValue = Number(voucher.discountValue);
    return {
      id: voucher.id,
      code: voucher.code,
      name: voucher.name,
      description: voucher.description,
      discountType: voucher.discountType,
      discountValue,
      discountPercent:
        voucher.discountType === 'PERCENTAGE' ? discountValue : null,
      maxDiscount: voucher.maxDiscount ? Number(voucher.maxDiscount) : null,
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
