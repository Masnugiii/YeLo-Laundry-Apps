import { Injectable } from '@nestjs/common';
import {
  OrderPaymentStatus,
  OrderStatus,
  Prisma,
  TimelineType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { OrderQueryDto } from './dto/order-query.dto';
import {
  orderDetailSelect,
  orderListSelect,
  OrderDetailRecord,
} from './order.select';
import {
  buildInvoicePrefix,
  formatInvoiceNumber,
  parseInvoiceSequence,
} from './utils/order-number.util';

export interface CreateOrderItemInput {
  serviceId: string;
  servicePriceId: string;
  quantity: number;
  weight?: number;
  unitPrice: number;
  subtotal: number;
  notes?: string;
}

export interface CreateOrderInput {
  customerId: string;
  estimatedFinishDate: Date;
  pickupRequired: boolean;
  deliveryRequired: boolean;
  pickupAddressId?: string;
  deliveryAddressId?: string;
  paymentMethod?: Prisma.OrderCreateInput['paymentMethod'];
  notes?: string | null;
  createdByEmployeeId: string;
  items: CreateOrderItemInput[];
}

@Injectable()
export class OrderRepository {
  constructor(private readonly prisma: PrismaService) {}

  findMany(query: OrderQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);

    return this.prisma.$transaction([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: orderListSelect,
      }),
      this.prisma.order.count({ where }),
    ]);
  }

  findManyForExport(query: OrderQueryDto) {
    const where = this.buildWhereClause(query);
    return this.prisma.order.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      select: orderListSelect,
    });
  }

  findById(id: string) {
    return this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      select: orderDetailSelect,
    });
  }

  findActiveService(serviceId: string) {
    return this.prisma.service.findFirst({
      where: { id: serviceId, isActive: true, deletedAt: null },
      select: {
        id: true,
        serviceName: true,
        unitType: true,
        weight: true,
        category: { select: { code: true } },
      },
    });
  }

  findActiveServicePrice(serviceId: string) {
    const today = new Date();

    return this.prisma.servicePrice.findFirst({
      where: {
        serviceId,
        isActive: true,
        deletedAt: null,
        effectiveDate: { lte: today },
        OR: [{ expiredDate: null }, { expiredDate: { gte: today } }],
      },
      orderBy: { effectiveDate: 'desc' },
      select: { id: true, price: true },
    });
  }

  findCustomerAddress(customerId: string, addressId: string) {
    return this.prisma.customerAddress.findFirst({
      where: { id: addressId, customerId, deletedAt: null },
      select: { id: true },
    });
  }

  createOrder(input: CreateOrderInput): Promise<OrderDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const invoiceNumber = await this.generateInvoiceNumber(tx);
      const queueNumber = await this.generateQueueNumber(tx);

      const order = await tx.order.create({
        data: {
          queueNumber,
          invoiceNumber,
          customerId: input.customerId,
          estimatedFinishDate: input.estimatedFinishDate,
          pickupRequired: input.pickupRequired,
          deliveryRequired: input.deliveryRequired,
          pickupAddressId: input.pickupAddressId,
          deliveryAddressId: input.deliveryAddressId,
          paymentMethod: input.paymentMethod,
          notes: input.notes,
          orderStatus: OrderStatus.CREATED,
          paymentStatus: OrderPaymentStatus.UNPAID,
          createdByEmployeeId: input.createdByEmployeeId,
          items: {
            create: input.items.map((item) => ({
              serviceId: item.serviceId,
              servicePriceId: item.servicePriceId,
              quantity: item.quantity,
              weight: item.weight,
              unitPrice: item.unitPrice,
              subtotal: item.subtotal,
              notes: item.notes,
            })),
          },
        },
        select: { id: true },
      });

      await tx.orderStatusHistory.create({
        data: {
          orderId: order.id,
          previousStatus: null,
          currentStatus: OrderStatus.CREATED,
          changedByEmployeeId: input.createdByEmployeeId,
          notes: 'Order created',
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: order.id,
          timelineType: TimelineType.ORDER,
          title: 'Order Created',
          description: `Invoice ${invoiceNumber} created`,
          employeeId: input.createdByEmployeeId,
        },
      });

      const detail = await tx.order.findUniqueOrThrow({
        where: { id: order.id },
        select: orderDetailSelect,
      });

      return detail;
    });
  }

  updateOrder(
    id: string,
    data: Prisma.OrderUncheckedUpdateInput,
    employeeId: string,
  ): Promise<OrderDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      await tx.order.update({
        where: { id },
        data: {
          ...data,
          updatedByEmployeeId: employeeId,
        },
      });

      return tx.order.findUniqueOrThrow({
        where: { id },
        select: orderDetailSelect,
      });
    });
  }

  updateStatus(
    id: string,
    previousStatus: OrderStatus,
    currentStatus: OrderStatus,
    employeeId: string,
    notes?: string,
  ): Promise<OrderDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const updateData: Prisma.OrderUncheckedUpdateInput = {
        orderStatus: currentStatus,
        updatedByEmployeeId: employeeId,
      };

      if (currentStatus === OrderStatus.COMPLETED) {
        updateData.completedDate = new Date();
      }

      await tx.order.update({
        where: { id },
        data: updateData,
      });

      await tx.orderStatusHistory.create({
        data: {
          orderId: id,
          previousStatus,
          currentStatus,
          changedByEmployeeId: employeeId,
          notes,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: id,
          timelineType: TimelineType.ORDER,
          title: 'Status Updated',
          description: `Status changed from ${previousStatus} to ${currentStatus}`,
          employeeId,
        },
      });

      return tx.order.findUniqueOrThrow({
        where: { id },
        select: orderDetailSelect,
      });
    });
  }

  cancelOrder(
    id: string,
    previousStatus: OrderStatus,
    employeeId: string,
    reason: string,
  ): Promise<OrderDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      await tx.order.update({
        where: { id },
        data: {
          orderStatus: OrderStatus.CANCELLED,
          paymentStatus: OrderPaymentStatus.CANCELLED,
          deletedAt: new Date(),
          updatedByEmployeeId: employeeId,
        },
      });

      await tx.orderStatusHistory.create({
        data: {
          orderId: id,
          previousStatus,
          currentStatus: OrderStatus.CANCELLED,
          changedByEmployeeId: employeeId,
          notes: reason,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: id,
          timelineType: TimelineType.ORDER,
          title: 'Order Cancelled',
          description: reason,
          employeeId,
        },
      });

      return tx.order.findUniqueOrThrow({
        where: { id },
        select: orderDetailSelect,
      });
    });
  }

  async getStatistics() {
    const now = new Date();
    const startOfDay = new Date(now);
    startOfDay.setHours(0, 0, 0, 0);

    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const baseWhere: Prisma.OrderWhereInput = { deletedAt: null };

    const [
      totalOrders,
      todayOrders,
      completedOrders,
      cancelledOrders,
      revenueTodayAgg,
      revenueMonthAgg,
      completedRevenueAgg,
    ] = await this.prisma.$transaction([
      this.prisma.order.count({ where: baseWhere }),
      this.prisma.order.count({
        where: { ...baseWhere, orderDate: { gte: startOfDay } },
      }),
      this.prisma.order.count({
        where: { ...baseWhere, orderStatus: OrderStatus.COMPLETED },
      }),
      this.prisma.order.count({
        where: { orderStatus: OrderStatus.CANCELLED },
      }),
      this.prisma.payment.aggregate({
        where: {
          deletedAt: null,
          paymentStatus: 'PAID',
          paidAt: { gte: startOfDay },
        },
        _sum: { amount: true },
      }),
      this.prisma.payment.aggregate({
        where: {
          deletedAt: null,
          paymentStatus: 'PAID',
          paidAt: { gte: startOfMonth },
        },
        _sum: { amount: true },
      }),
      this.prisma.payment.aggregate({
        where: {
          deletedAt: null,
          paymentStatus: 'PAID',
          order: {
            deletedAt: null,
            orderStatus: OrderStatus.COMPLETED,
          },
        },
        _sum: { amount: true },
      }),
    ]);

    const revenueToday = Number(revenueTodayAgg._sum.amount ?? 0);
    const revenueThisMonth = Number(revenueMonthAgg._sum.amount ?? 0);
    const completedRevenue = Number(completedRevenueAgg._sum.amount ?? 0);
    const averageTicket =
      completedOrders > 0
        ? Number((completedRevenue / completedOrders).toFixed(2))
        : 0;

    return {
      totalOrders,
      todayOrders,
      completedOrders,
      cancelledOrders,
      revenueToday,
      revenueThisMonth,
      averageTicket,
    };
  }

  private async generateInvoiceNumber(tx: Prisma.TransactionClient) {
    const prefix = buildInvoicePrefix();
    const latest = await tx.order.findFirst({
      where: { invoiceNumber: { startsWith: prefix } },
      orderBy: { invoiceNumber: 'desc' },
      select: { invoiceNumber: true },
    });

    const latestSequence = latest?.invoiceNumber
      ? parseInvoiceSequence(latest.invoiceNumber, prefix)
      : null;

    return formatInvoiceNumber((latestSequence ?? 0) + 1);
  }

  private async generateQueueNumber(tx: Prisma.TransactionClient) {
    const settings = await tx.queueSetting.findFirst({
      orderBy: { createdAt: 'asc' },
    });

    const prefix = settings?.prefix ?? 'Q';
    const dailyReset = settings?.dailyReset ?? true;
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const where: Prisma.OrderWhereInput = dailyReset
      ? { orderDate: { gte: startOfDay }, deletedAt: null }
      : { deletedAt: null };

    const count = await tx.order.count({ where });
    const sequence = (settings?.startingNumber ?? 1) + count;

    return `${prefix}-${String(sequence).padStart(4, '0')}`;
  }

  private buildWhereClause(query: OrderQueryDto): Prisma.OrderWhereInput {
    const where: Prisma.OrderWhereInput = { deletedAt: null };

    if (query.status) {
      where.orderStatus = query.status;
    }

    if (query.paymentStatus) {
      where.paymentStatus = query.paymentStatus;
    }

    if (query.customerId) {
      where.customerId = query.customerId;
    }

    if (query.employeeId) {
      where.createdByEmployeeId = query.employeeId;
    }

    if (query.pickupStatus) {
      where.pickupJob = { status: query.pickupStatus };
    }

    if (query.deliveryStatus) {
      where.deliveryJob = { status: query.deliveryStatus };
    }

    if (query.dateFrom || query.dateTo) {
      where.orderDate = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    const filters: Prisma.OrderWhereInput[] = [];

    if (query.search?.trim()) {
      const keyword = query.search.trim();
      filters.push({
        OR: [
          { invoiceNumber: { contains: keyword, mode: 'insensitive' } },
          { queueNumber: { contains: keyword, mode: 'insensitive' } },
          { customer: { fullName: { contains: keyword, mode: 'insensitive' } } },
          { customer: { phone: { contains: keyword, mode: 'insensitive' } } },
        ],
      });
    }

    if (query.serviceType?.trim()) {
      const serviceType = query.serviceType.trim();
      filters.push({
        items: {
          some: {
            deletedAt: null,
            OR: [
              { serviceId: serviceType },
              {
                service: {
                  category: {
                    code: { equals: serviceType, mode: 'insensitive' },
                  },
                },
              },
              {
                service: {
                  serviceCode: { equals: serviceType, mode: 'insensitive' },
                },
              },
            ],
          },
        },
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
