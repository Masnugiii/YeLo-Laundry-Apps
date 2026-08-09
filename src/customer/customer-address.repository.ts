import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { CustomerAddressQueryDto } from './dto/customer-address-query.dto';
import { customerAddressSelect } from './customer-address.select';

@Injectable()
export class CustomerAddressRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByCustomerId(customerId: string, query?: CustomerAddressQueryDto) {
    return this.prisma.customerAddress.findMany({
      where: this.buildWhereClause(customerId, query),
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
      select: customerAddressSelect,
    });
  }

  findById(customerId: string, addressId: string) {
    return this.prisma.customerAddress.findFirst({
      where: {
        id: addressId,
        customerId,
        deletedAt: null,
      },
      select: customerAddressSelect,
    });
  }

  create(
    customerId: string,
    data: {
      recipientName: string;
      phone: string;
      province: string;
      city: string;
      district: string;
      postalCode?: string | null;
      addressDetail: string;
      latitude?: number;
      longitude?: number;
      isDefault: boolean;
    },
  ) {
    return this.prisma.$transaction(async (tx) => {
      if (data.isDefault) {
        await this.clearDefaultAddress(tx, customerId);
      }

      const address = await tx.customerAddress.create({
        data: {
          customerId,
          recipientName: data.recipientName,
          phone: data.phone,
          province: data.province,
          city: data.city,
          district: data.district,
          postalCode: data.postalCode,
          addressDetail: data.addressDetail,
          latitude: data.latitude,
          longitude: data.longitude,
          isDefault: data.isDefault,
        },
        select: customerAddressSelect,
      });

      if (data.isDefault) {
        await tx.customer.update({
          where: { id: customerId },
          data: { defaultAddressId: address.id },
        });
      }

      return address;
    });
  }

  update(
    customerId: string,
    addressId: string,
    data: Prisma.CustomerAddressUpdateInput & { isDefault?: boolean },
  ) {
    return this.prisma.$transaction(async (tx) => {
      if (data.isDefault === true) {
        await this.clearDefaultAddress(tx, customerId, addressId);
      }

      const address = await tx.customerAddress.update({
        where: { id: addressId },
        data,
        select: customerAddressSelect,
      });

      if (data.isDefault === true) {
        await tx.customer.update({
          where: { id: customerId },
          data: { defaultAddressId: addressId },
        });
      }

      if (data.isDefault === false) {
        const customer = await tx.customer.findUnique({
          where: { id: customerId },
          select: { defaultAddressId: true },
        });

        if (customer?.defaultAddressId === addressId) {
          await tx.customer.update({
            where: { id: customerId },
            data: { defaultAddressId: null },
          });
        }
      }

      return address;
    });
  }

  softDelete(customerId: string, addressId: string) {
    return this.prisma.$transaction(async (tx) => {
      const customer = await tx.customer.findUnique({
        where: { id: customerId },
        select: { defaultAddressId: true },
      });

      await tx.customerAddress.update({
        where: { id: addressId },
        data: { deletedAt: new Date(), isDefault: false },
      });

      if (customer?.defaultAddressId === addressId) {
        await tx.customer.update({
          where: { id: customerId },
          data: { defaultAddressId: null },
        });
      }
    });
  }

  private buildWhereClause(
    customerId: string,
    query?: CustomerAddressQueryDto,
  ): Prisma.CustomerAddressWhereInput {
    const where: Prisma.CustomerAddressWhereInput = {
      customerId,
      deletedAt: null,
    };

    const filters: Prisma.CustomerAddressWhereInput[] = [];

    if (query?.label?.trim()) {
      const keyword = query.label.trim();
      filters.push({
        OR: [
          { addressDetail: { contains: keyword, mode: 'insensitive' } },
          { district: { contains: keyword, mode: 'insensitive' } },
          { city: { contains: keyword, mode: 'insensitive' } },
        ],
      });
    }

    if (query?.recipientName?.trim()) {
      filters.push({
        recipientName: {
          contains: query.recipientName.trim(),
          mode: 'insensitive',
        },
      });
    }

    if (query?.phone?.trim()) {
      filters.push({
        phone: { contains: query.phone.trim(), mode: 'insensitive' },
      });
    }

    if (filters.length === 1) {
      Object.assign(where, filters[0]);
    } else if (filters.length > 1) {
      where.AND = filters;
    }

    return where;
  }

  private async clearDefaultAddress(
    tx: Prisma.TransactionClient,
    customerId: string,
    excludeAddressId?: string,
  ) {
    await tx.customerAddress.updateMany({
      where: {
        customerId,
        deletedAt: null,
        ...(excludeAddressId ? { id: { not: excludeAddressId } } : {}),
      },
      data: { isDefault: false },
    });
  }
}
