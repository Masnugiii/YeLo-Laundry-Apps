import { Injectable } from '@nestjs/common';
import { OrderStatus, PaymentStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { NumberingService } from '../numbering/numbering.service';
import { CustomerQueryDto, CustomerSortField, SortOrder } from './dto/customer-query.dto';
import {
  customerDetailSelect,
  customerListSelect,
  customerSearchSelect,
} from './customer.select';

@Injectable()
export class CustomerRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly numberingService: NumberingService,
  ) {}

  findMany(query: CustomerQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);
    const orderBy = this.buildOrderBy(query);

    return this.prisma.$transaction([
      this.prisma.customer.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        select: customerListSelect,
      }),
      this.prisma.customer.count({ where }),
    ]);
  }

  getOrderStatsByCustomerIds(customerIds: string[]) {
    if (!customerIds.length) {
      return Promise.resolve(
        new Map<string, { totalOrders: number; totalSpending: number; lastOrderAt: Date | null }>(),
      );
    }

    return this.prisma.order
      .groupBy({
        by: ['customerId'],
        where: {
          customerId: { in: customerIds },
          deletedAt: null,
        },
        _count: { _all: true },
        _max: { orderDate: true },
      })
      .then(async (groups) => {
        const paymentGroups = await this.prisma.payment.groupBy({
          by: ['orderId'],
          where: {
            deletedAt: null,
            paymentStatus: PaymentStatus.PAID,
            order: {
              customerId: { in: customerIds },
              deletedAt: null,
            },
          },
          _sum: { amount: true },
        });

        const orderCustomerMap = await this.prisma.order.findMany({
          where: {
            id: { in: paymentGroups.map((group) => group.orderId) },
            deletedAt: null,
          },
          select: { id: true, customerId: true },
        });

        const spendingByCustomer = new Map<string, number>();
        for (const payment of paymentGroups) {
          const order = orderCustomerMap.find((item) => item.id === payment.orderId);
          if (!order) continue;
          const current = spendingByCustomer.get(order.customerId) ?? 0;
          spendingByCustomer.set(
            order.customerId,
            current + Number(payment._sum.amount ?? 0),
          );
        }

        return new Map(
          groups.map((group) => [
            group.customerId,
            {
              totalOrders: group._count._all,
              totalSpending: spendingByCustomer.get(group.customerId) ?? 0,
              lastOrderAt: group._max.orderDate,
            },
          ]),
        );
      });
  }

  getBusinessSummary(customerId: string) {
    return this.prisma.$transaction(async (tx) => {
      const [totalOrders, completedOrders, cancelledOrders, lastOrder, payments] =
        await Promise.all([
          tx.order.count({
            where: { customerId, deletedAt: null },
          }),
          tx.order.count({
            where: {
              customerId,
              deletedAt: null,
              orderStatus: OrderStatus.COMPLETED,
            },
          }),
          tx.order.count({
            where: {
              customerId,
              deletedAt: null,
              orderStatus: OrderStatus.CANCELLED,
            },
          }),
          tx.order.findFirst({
            where: { customerId, deletedAt: null },
            orderBy: { orderDate: 'desc' },
            select: { orderDate: true },
          }),
          tx.payment.findMany({
            where: {
              deletedAt: null,
              paymentStatus: PaymentStatus.PAID,
              order: { customerId, deletedAt: null },
            },
            select: { amount: true },
          }),
        ]);

      const totalSpending = payments.reduce(
        (sum, payment) => sum + Number(payment.amount),
        0,
      );

      return {
        totalOrders,
        completedOrders,
        cancelledOrders,
        totalSpending,
        averageOrderValue:
          totalOrders > 0 ? Number((totalSpending / totalOrders).toFixed(2)) : 0,
        lastOrderAt: lastOrder?.orderDate ?? null,
      };
    });
  }

  findManyForExport(query: CustomerQueryDto) {
    const where = this.buildWhereClause(query);
    const orderBy = this.buildOrderBy(query);

    return this.prisma.customer.findMany({
      where,
      orderBy,
      select: customerListSelect,
    });
  }

  search(keyword: string, limit: number) {
    const where: Prisma.CustomerWhereInput = {
      deletedAt: null,
      OR: [
        { customerCode: { contains: keyword, mode: 'insensitive' } },
        { fullName: { contains: keyword, mode: 'insensitive' } },
        { phone: { contains: keyword, mode: 'insensitive' } },
      ],
    };

    return this.prisma.customer.findMany({
      where,
      take: limit,
      orderBy: { fullName: 'asc' },
      select: customerSearchSelect,
    });
  }

  findById(id: string, includeDeleted = false) {
    return this.prisma.customer.findFirst({
      where: {
        id,
        ...(includeDeleted ? {} : { deletedAt: null }),
      },
      select: customerDetailSelect,
    });
  }

  findByPhone(phone: string, excludeId?: string) {
    return this.prisma.customer.findFirst({
      where: {
        phone,
        deletedAt: null,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
      select: { id: true },
    });
  }

  findActiveByPhone(phone: string) {
    return this.prisma.customer.findFirst({
      where: {
        phone,
        deletedAt: null,
        isActive: true,
      },
      select: {
        id: true,
        phone: true,
        fullName: true,
        email: true,
        photoUrl: true,
        isActive: true,
        customerCode: true,
      },
    });
  }

  findByEmail(email: string, excludeId?: string) {
    return this.prisma.customer.findFirst({
      where: {
        email,
        deletedAt: null,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
      select: { id: true },
    });
  }

  findLatestCustomerCode() {
    return this.prisma.customer.findFirst({
      where: {
        customerCode: { startsWith: 'CUS-', mode: 'insensitive' },
      },
      orderBy: { customerCode: 'desc' },
      select: { customerCode: true },
    });
  }

  countOpenOrders(customerId: string) {
    return this.prisma.order.count({
      where: {
        customerId,
        deletedAt: null,
        orderStatus: {
          notIn: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
        },
      },
    });
  }

  createWithWallet(data: {
    customerCode: string;
    fullName: string;
    phone: string;
    email: string | null;
    gender?: Prisma.CustomerCreateInput['gender'];
    age?: number | null;
    occupation?: string | null;
    birthDate?: Date;
    isActive: boolean;
    photoUrl?: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const customer = await tx.customer.create({
        data: {
          customerCode: data.customerCode,
          fullName: data.fullName,
          phone: data.phone,
          email: data.email,
          gender: data.gender,
          age: data.age,
          occupation: data.occupation,
          birthDate: data.birthDate,
          isActive: data.isActive,
          photoUrl: data.photoUrl,
          wallet: {
            create: {
              currentBalance: 0,
              currency: 'IDR',
              isActive: true,
            },
          },
        },
        select: customerDetailSelect,
      });

      return customer;
    });
  }

  update(id: string, data: Prisma.CustomerUpdateInput) {
    return this.prisma.customer.update({
      where: { id },
      data,
      select: customerDetailSelect,
    });
  }

  softDelete(id: string) {
    return this.prisma.customer.update({
      where: { id },
      data: { deletedAt: new Date(), isActive: false },
      select: { id: true },
    });
  }

  restore(id: string) {
    return this.prisma.customer.update({
      where: { id },
      data: { deletedAt: null },
      select: customerDetailSelect,
    });
  }

  async generateNextCustomerCode() {
    return this.numberingService.generateNumber('CST');
  }

  private buildOrderBy(
    query: CustomerQueryDto,
  ): Prisma.CustomerOrderByWithRelationInput {
    const sortBy = query.sortBy ?? CustomerSortField.CREATED_AT;
    const sortOrder = query.sortOrder ?? SortOrder.DESC;

    return { [sortBy]: sortOrder };
  }

  private buildWhereClause(query: CustomerQueryDto): Prisma.CustomerWhereInput {
    const where: Prisma.CustomerWhereInput = {};

    if (query.deleted) {
      where.deletedAt = { not: null };
    } else {
      where.deletedAt = null;
    }

    if (query.isActive !== undefined) {
      where.isActive = query.isActive;
    }

    if (query.dateFrom || query.dateTo) {
      where.createdAt = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    if (query.isMember === true) {
      where.rewardPoints = { some: { point: { gt: 0 } } };
    } else if (query.isMember === false) {
      where.OR = [
        { rewardPoints: { none: {} } },
        { rewardPoints: { every: { point: { lte: 0 } } } },
      ];
    }

    const fieldFilters: Prisma.CustomerWhereInput[] = [];

    if (query.customerCode?.trim()) {
      fieldFilters.push({
        customerCode: {
          contains: query.customerCode.trim(),
          mode: 'insensitive',
        },
      });
    }

    if (query.fullName?.trim()) {
      fieldFilters.push({
        fullName: { contains: query.fullName.trim(), mode: 'insensitive' },
      });
    }

    if (query.phone?.trim()) {
      fieldFilters.push({
        phone: { contains: query.phone.trim(), mode: 'insensitive' },
      });
    }

    if (query.email?.trim()) {
      fieldFilters.push({
        email: { contains: query.email.trim(), mode: 'insensitive' },
      });
    }

    if (query.search?.trim()) {
      const keyword = query.search.trim();
      fieldFilters.push({
        OR: [
          { customerCode: { contains: keyword, mode: 'insensitive' } },
          { fullName: { contains: keyword, mode: 'insensitive' } },
          { phone: { contains: keyword, mode: 'insensitive' } },
          { email: { contains: keyword, mode: 'insensitive' } },
        ],
      });
    }

    if (fieldFilters.length === 1) {
      Object.assign(where, fieldFilters[0]);
    } else if (fieldFilters.length > 1) {
      where.AND = fieldFilters;
    }

    return where;
  }
}
