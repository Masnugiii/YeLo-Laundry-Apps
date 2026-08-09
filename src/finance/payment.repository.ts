import { Injectable } from '@nestjs/common';
import {
  CashflowType,
  OrderPaymentStatus,
  OrderStatus,
  PaymentStatus,
  Prisma,
  ReferenceType,
  TimelineType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { OrderStatusTransitionService } from '../order/order-status-transition.service';
import { decodeOrderNotes } from '../order/utils/order-meta.util';
import { calculateOrderTotals } from '../order/order.mapper';
import { PaymentQueryDto } from './dto/payment.dto';
import {
  paymentDetailSelect,
  paymentListSelect,
  PaymentDetailRecord,
} from './payment.select';
import { encodePaymentNotes } from './utils/payment-meta.util';
import { FinanceSettingsRepository } from './finance-settings.repository';

export interface CreatePaymentInput {
  orderId: string;
  paymentMethodId: string;
  amount: number;
  paymentStatus: PaymentStatus;
  referenceNumber: string;
  receivedByEmployeeId: string;
  notes?: string | null;
}

export interface UpdatePaymentInput {
  amount?: number;
  paymentStatus?: PaymentStatus;
  notes?: string | null;
}

@Injectable()
export class PaymentRepository {
  constructor(
    private readonly prisma: PrismaService,
    private readonly financeSettings: FinanceSettingsRepository,
    private readonly orderStatusTransitionService: OrderStatusTransitionService,
  ) {}

  findMany(query: PaymentQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);

    return this.prisma.$transaction([
      this.prisma.payment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: paymentListSelect,
      }),
      this.prisma.payment.count({ where }),
    ]);
  }

  findById(id: string): Promise<PaymentDetailRecord | null> {
    return this.prisma.payment.findFirst({
      where: { id, deletedAt: null },
      select: paymentDetailSelect,
    });
  }

  findPaymentMethodByCode(code: string) {
    return this.prisma.paymentMethod.findFirst({
      where: { code, isActive: true, deletedAt: null },
      select: { id: true, code: true, name: true },
    });
  }

  findOrderForPayment(orderId: string) {
    return this.prisma.order.findFirst({
      where: { id: orderId, deletedAt: null },
      select: {
        id: true,
        customerId: true,
        invoiceNumber: true,
        paymentStatus: true,
        orderStatus: true,
        notes: true,
        items: {
          where: { deletedAt: null },
          select: { subtotal: true },
        },
        payments: {
          where: { deletedAt: null },
          select: {
            id: true,
            amount: true,
            paymentStatus: true,
          },
        },
      },
    });
  }

  async getPaidTotalForOrder(orderId: string, tx?: Prisma.TransactionClient) {
    const client = tx ?? this.prisma;
    const aggregate = await client.payment.aggregate({
      where: {
        orderId,
        deletedAt: null,
        paymentStatus: PaymentStatus.PAID,
      },
      _sum: { amount: true },
    });

    return Number(aggregate._sum.amount ?? 0);
  }

  getOrderGrandTotal(
    order: NonNullable<Awaited<ReturnType<PaymentRepository['findOrderForPayment']>>>,
  ): number {
    const { meta } = decodeOrderNotes(order.notes);
    const itemsSubtotal = order.items.reduce(
      (sum, item) => sum + Number(item.subtotal),
      0,
    );

    return calculateOrderTotals(itemsSubtotal, meta).grandTotal;
  }

  createPayment(input: CreatePaymentInput): Promise<PaymentDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const duplicate = await tx.payment.findFirst({
        where: {
          orderId: input.orderId,
          referenceNumber: input.referenceNumber,
          deletedAt: null,
        },
        select: { id: true },
      });

      if (duplicate) {
        throw new Error('DUPLICATE_PAYMENT');
      }

      const payment = await tx.payment.create({
        data: {
          orderId: input.orderId,
          paymentMethodId: input.paymentMethodId,
          amount: input.amount,
          paymentStatus: input.paymentStatus,
          referenceNumber: input.referenceNumber,
          receivedByEmployeeId: input.receivedByEmployeeId,
          notes: input.notes,
        },
        select: paymentDetailSelect,
      });

      if (input.paymentStatus === PaymentStatus.PAID) {
        await this.applyPaidSideEffects(tx, payment.id, input.receivedByEmployeeId);
      }

      return payment;
    });
  }

  updatePayment(
    id: string,
    input: UpdatePaymentInput,
    employeeId: string,
  ): Promise<PaymentDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.payment.findFirst({
        where: { id, deletedAt: null },
        select: {
          id: true,
          orderId: true,
          paymentStatus: true,
          amount: true,
        },
      });

      if (!existing) {
        throw new Error('NOT_FOUND');
      }

      if (
        existing.paymentStatus === PaymentStatus.REFUNDED ||
        existing.paymentStatus === PaymentStatus.CANCELLED
      ) {
        throw new Error('FINALIZED');
      }

      const payment = await tx.payment.update({
        where: { id },
        data: {
          ...(input.amount !== undefined ? { amount: input.amount } : {}),
          ...(input.paymentStatus ? { paymentStatus: input.paymentStatus } : {}),
          ...(input.notes !== undefined ? { notes: input.notes } : {}),
        },
        select: paymentDetailSelect,
      });

      if (
        input.paymentStatus === PaymentStatus.PAID &&
        existing.paymentStatus !== PaymentStatus.PAID
      ) {
        await this.applyPaidSideEffects(tx, id, employeeId);
      } else if (input.paymentStatus || input.amount !== undefined) {
        await this.syncOrderPaymentStatus(tx, existing.orderId);
      }

      return payment;
    });
  }

  softDelete(id: string, employeeId: string): Promise<PaymentDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.payment.findFirst({
        where: { id, deletedAt: null },
        select: { id: true, orderId: true, paymentStatus: true },
      });

      if (!existing) {
        throw new Error('NOT_FOUND');
      }

      if (existing.paymentStatus === PaymentStatus.REFUNDED) {
        throw new Error('FINALIZED');
      }

      const payment = await tx.payment.update({
        where: { id },
        data: {
          paymentStatus: PaymentStatus.CANCELLED,
          deletedAt: new Date(),
        },
        select: paymentDetailSelect,
      });

      await this.syncOrderPaymentStatus(tx, existing.orderId);

      await tx.orderTimeline.create({
        data: {
          orderId: existing.orderId,
          timelineType: TimelineType.PAYMENT,
          title: 'Payment voided',
          description: `Payment ${payment.referenceNumber ?? id} voided`,
          employeeId,
        },
      });

      return payment;
    });
  }

  refundPayment(
    id: string,
    amount: number,
    reason: string,
    employeeId: string,
    refundReference: string,
    updatedNotes: string | null,
    isFullRefund: boolean,
  ): Promise<PaymentDetailRecord> {
    return this.prisma.$transaction(async (tx) => {
      const payment = await tx.payment.update({
        where: { id },
        data: {
          paymentStatus: isFullRefund
            ? PaymentStatus.REFUNDED
            : PaymentStatus.PAID,
          notes: updatedNotes,
        },
        select: paymentDetailSelect,
      });

      await tx.cashflow.create({
        data: {
          type: CashflowType.EXPENSE,
          referenceType: ReferenceType.REFUND,
          referenceId: payment.id,
          amount,
          transactionDate: new Date(),
          description: `${refundReference} | ${reason}`,
          createdByEmployeeId: employeeId,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: payment.orderId,
          timelineType: TimelineType.PAYMENT,
          title: isFullRefund ? 'Payment refunded' : 'Partial refund issued',
          description: `${refundReference}: ${reason}`,
          employeeId,
        },
      });

      await this.syncOrderPaymentStatus(tx, payment.orderId, isFullRefund);

      return payment;
    });
  }

  private async applyPaidSideEffects(
    tx: Prisma.TransactionClient,
    paymentId: string,
    employeeId: string,
  ) {
    const payment = await tx.payment.findUniqueOrThrow({
      where: { id: paymentId },
      select: {
        id: true,
        orderId: true,
        amount: true,
        referenceNumber: true,
        order: {
          select: {
            customerId: true,
            invoiceNumber: true,
            orderStatus: true,
            pickupRequired: true,
            notes: true,
            items: {
              where: { deletedAt: null },
              select: { subtotal: true },
            },
          },
        },
      },
    });

    await tx.cashflow.create({
      data: {
        type: CashflowType.INCOME,
        referenceType: ReferenceType.ORDER_PAYMENT,
        referenceId: payment.id,
        amount: payment.amount,
        transactionDate: new Date(),
        description: `Payment ${payment.referenceNumber ?? payment.id}`,
        createdByEmployeeId: employeeId,
      },
    });

    await tx.orderTimeline.create({
      data: {
        orderId: payment.orderId,
        timelineType: TimelineType.PAYMENT,
        title: 'Payment received',
        description: `Payment ${payment.referenceNumber ?? payment.id} recorded`,
        employeeId,
      },
    });

    await this.syncOrderPaymentStatus(tx, payment.orderId);

    const grandTotal = this.getOrderGrandTotal({
      id: payment.orderId,
      ...payment.order,
      customerId: payment.order.customerId,
      invoiceNumber: payment.order.invoiceNumber,
      paymentStatus: OrderPaymentStatus.UNPAID,
      orderStatus: payment.order.orderStatus,
      payments: [],
    });

    const paidTotal = await this.getPaidTotalForOrder(payment.orderId, tx);
    const isFullyPaid = paidTotal >= grandTotal && grandTotal > 0;
    const nextStatus = this.orderStatusTransitionService.resolveStatusAfterPayment(
      payment.order.orderStatus,
      {
        pickupRequired: payment.order.pickupRequired,
        isFullyPaid,
      },
    );

    if (nextStatus && nextStatus !== payment.order.orderStatus) {
      await tx.order.update({
        where: { id: payment.orderId },
        data: { orderStatus: nextStatus },
      });

      await tx.orderStatusHistory.create({
        data: {
          orderId: payment.orderId,
          previousStatus: payment.order.orderStatus,
          currentStatus: nextStatus,
          changedByEmployeeId: employeeId,
          notes: 'Payment received',
        },
      });
    }

    const existingInvoice = await this.financeSettings.getInvoiceByOrderId(
      payment.orderId,
    );

    if (!existingInvoice) {
      const invoiceNumber = await this.financeSettings.generateReferenceNumber(
        'INV',
        tx,
      );

      await this.financeSettings.saveInvoice(
        {
          invoiceNumber,
          orderId: payment.orderId,
          customerId: payment.order.customerId,
          orderNumber: payment.order.invoiceNumber,
          amount: grandTotal,
          status: 'ISSUED',
          generatedAt: new Date().toISOString(),
          generatedByEmployeeId: employeeId,
        },
        tx,
      );
    }
  }

  private async syncOrderPaymentStatus(
    tx: Prisma.TransactionClient,
    orderId: string,
    forceRefund = false,
  ) {
    const order = await tx.order.findUniqueOrThrow({
      where: { id: orderId },
      select: {
        id: true,
        notes: true,
        items: {
          where: { deletedAt: null },
          select: { subtotal: true },
        },
        payments: {
          where: { deletedAt: null },
          select: {
            amount: true,
            paymentStatus: true,
            notes: true,
          },
        },
      },
    });

    const grandTotal = this.getOrderGrandTotal({
      ...order,
      customerId: '',
      invoiceNumber: '',
      paymentStatus: OrderPaymentStatus.UNPAID,
      orderStatus: 'CREATED' as const,
      payments: order.payments.map((payment) => ({
        id: '',
        amount: payment.amount,
        paymentStatus: payment.paymentStatus,
      })),
    });

    const paidTotal = order.payments
      .filter((payment) => payment.paymentStatus === PaymentStatus.PAID)
      .reduce((sum, payment) => sum + Number(payment.amount), 0);

    const refundedPayments = order.payments.filter(
      (payment) => payment.paymentStatus === PaymentStatus.REFUNDED,
    );

    let paymentStatus: OrderPaymentStatus = OrderPaymentStatus.UNPAID;

    if (forceRefund || refundedPayments.length > 0) {
      const allRefunded = order.payments.every(
        (payment) =>
          payment.paymentStatus === PaymentStatus.REFUNDED ||
          payment.paymentStatus === PaymentStatus.CANCELLED,
      );

      if (allRefunded && order.payments.length > 0) {
        paymentStatus = OrderPaymentStatus.REFUNDED;
      } else if (paidTotal <= 0 && refundedPayments.length > 0) {
        paymentStatus = OrderPaymentStatus.REFUNDED;
      } else if (paidTotal >= grandTotal) {
        paymentStatus = OrderPaymentStatus.PAID;
      }
    } else if (paidTotal >= grandTotal && grandTotal > 0) {
      paymentStatus = OrderPaymentStatus.PAID;
    }

    await tx.order.update({
      where: { id: orderId },
      data: { paymentStatus },
    });
  }

  private buildWhereClause(query: PaymentQueryDto): Prisma.PaymentWhereInput {
    const where: Prisma.PaymentWhereInput = { deletedAt: null };

    if (query.orderId) {
      where.orderId = query.orderId;
    }

    if (query.customerId) {
      where.order = { customerId: query.customerId };
    }

    if (query.employeeId) {
      where.receivedByEmployeeId = query.employeeId;
    }

    if (query.paymentStatus) {
      where.paymentStatus = query.paymentStatus;
    }

    if (query.paymentMethod) {
      const dbCode =
        query.paymentMethod === 'CUSTOMER_WALLET'
          ? 'YELO_WALLET'
          : query.paymentMethod;

      where.paymentMethod = { code: dbCode };
    }

    if (query.dateFrom || query.dateTo) {
      where.paidAt = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    if (query.search) {
      const search = query.search.trim();
      where.OR = [
        { referenceNumber: { contains: search, mode: 'insensitive' } },
        {
          order: {
            invoiceNumber: { contains: search, mode: 'insensitive' },
          },
        },
        {
          order: {
            customer: {
              OR: [
                { fullName: { contains: search, mode: 'insensitive' } },
                { phone: { contains: search, mode: 'insensitive' } },
              ],
            },
          },
        },
      ];
    }

    return where;
  }
}
