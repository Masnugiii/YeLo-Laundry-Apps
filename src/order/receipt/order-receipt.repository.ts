import { Injectable } from '@nestjs/common';
import {
  OrderPaymentStatus,
  OrderReceiptDeliveryStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../../database/prisma/prisma.service';

@Injectable()
export class OrderReceiptRepository {
  constructor(private readonly prisma: PrismaService) {}

  createDelivery(data: {
    orderId: string;
    messageText: string;
    paymentStatusSnapshot: OrderPaymentStatus;
    paymentMethodSnapshot: string | null;
    customerPhone: string | null;
    deliveryStatus: OrderReceiptDeliveryStatus;
    failureReason?: string | null;
    sentAt?: Date | null;
    createdByEmployeeId: string;
  }) {
    return this.prisma.orderReceiptDelivery.create({
      data,
    });
  }

  updateDelivery(
    id: string,
    data: Prisma.OrderReceiptDeliveryUpdateInput,
  ) {
    return this.prisma.orderReceiptDelivery.update({
      where: { id },
      data,
    });
  }

  findByOrderId(orderId: string) {
    return this.prisma.orderReceiptDelivery.findMany({
      where: { orderId },
      orderBy: { createdAt: 'desc' },
    });
  }

  findById(id: string) {
    return this.prisma.orderReceiptDelivery.findUnique({
      where: { id },
    });
  }
}
