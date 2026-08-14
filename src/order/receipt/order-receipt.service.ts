import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderPaymentStatus, OrderReceiptDeliveryStatus } from '@prisma/client';
import { AdminSettingsService } from '../../admin/admin-settings.service';
import { ApiSuccessResponse } from '../../common/interfaces/api-response.interface';
import { OrderRepository } from '../order.repository';
import { calculateOrderTotals, toOrderListItem } from '../order.mapper';
import { decodeOrderNotes } from '../utils/order-meta.util';
import { buildOrderReceiptMessage } from './order-receipt-message.builder';
import { OrderReceiptRepository } from './order-receipt.repository';
import { OrderReceiptResponse } from './order-receipt.types';
import { UnconfiguredWhatsappProvider } from './unconfigured-whatsapp.provider';

@Injectable()
export class OrderReceiptService {
  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly orderReceiptRepository: OrderReceiptRepository,
    private readonly adminSettingsService: AdminSettingsService,
    private readonly whatsappProvider: UnconfiguredWhatsappProvider,
  ) {}

  async generateReceipt(
    orderId: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderReceiptResponse>> {
    const order = await this.requireOrder(orderId);
    const detail = toOrderListItem(order as never);
    const messageText = await this.buildMessageFromOrder(order);
    const paymentMethodSnapshot =
      order.paymentStatus === OrderPaymentStatus.PAID
        ? order.paymentMethod
        : null;

    const delivery = await this.orderReceiptRepository.createDelivery({
      orderId,
      messageText,
      paymentStatusSnapshot: order.paymentStatus,
      paymentMethodSnapshot,
      customerPhone: order.customer.phone,
      deliveryStatus: OrderReceiptDeliveryStatus.PENDING,
      createdByEmployeeId: employeeId,
    });

    return {
      success: true,
      message: 'Receipt generated successfully',
      data: this.toResponse(delivery.id, detail, messageText, order),
    };
  }

  async sendViaWhatsapp(
    orderId: string,
    receiptId: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderReceiptResponse>> {
    const order = await this.requireOrder(orderId);
    const detail = toOrderListItem(order as never);
    const receipt = await this.orderReceiptRepository.findById(receiptId);

    if (!receipt || receipt.orderId !== orderId) {
      throw new NotFoundException('Receipt not found');
    }

    if (!order.customer.phone?.trim()) {
      throw new BadRequestException('Nomor WhatsApp customer belum tersedia.');
    }

    const freshMessage = await this.buildMessageFromOrder(order);
    const result = await this.whatsappProvider.sendMessage(
      order.customer.phone,
      freshMessage,
    );

    if (result.status === 'SENT') {
      const updated = await this.orderReceiptRepository.updateDelivery(receipt.id, {
        messageText: freshMessage,
        paymentStatusSnapshot: order.paymentStatus,
        paymentMethodSnapshot:
          order.paymentStatus === OrderPaymentStatus.PAID
            ? order.paymentMethod
            : null,
        customerPhone: order.customer.phone,
        deliveryStatus: OrderReceiptDeliveryStatus.SENT,
        failureReason: null,
        sentAt: result.sentAt,
      });

      return {
        success: true,
        message: 'Receipt sent via WhatsApp',
        data: this.toResponse(
          updated.id,
          detail,
          updated.messageText,
          order,
          OrderReceiptDeliveryStatus.SENT,
          null,
          result.sentAt,
        ),
      };
    }

    const deliveryStatus =
      result.status === 'NOT_CONFIGURED'
        ? OrderReceiptDeliveryStatus.NOT_CONFIGURED
        : OrderReceiptDeliveryStatus.FAILED;

    const updated = await this.orderReceiptRepository.updateDelivery(receipt.id, {
      messageText: freshMessage,
      paymentStatusSnapshot: order.paymentStatus,
      paymentMethodSnapshot:
        order.paymentStatus === OrderPaymentStatus.PAID
          ? order.paymentMethod
          : null,
      customerPhone: order.customer.phone,
      deliveryStatus,
      failureReason: result.reason,
      sentAt: null,
    });

    return {
      success: true,
      message:
        result.status === 'NOT_CONFIGURED'
          ? 'WhatsApp provider is not configured'
          : 'Failed to send receipt via WhatsApp',
      data: this.toResponse(
        updated.id,
        detail,
        updated.messageText,
        order,
        deliveryStatus,
        result.reason,
        null,
      ),
    };
  }

  async recordManualHandoff(
    orderId: string,
    receiptId: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderReceiptResponse>> {
    const order = await this.requireOrder(orderId);
    const detail = toOrderListItem(order as never);
    const receipt = await this.orderReceiptRepository.findById(receiptId);

    if (!receipt || receipt.orderId !== orderId) {
      throw new NotFoundException('Receipt not found');
    }

    if (!order.customer.phone?.trim()) {
      throw new BadRequestException('Nomor WhatsApp customer belum tersedia.');
    }

    const freshMessage = await this.buildMessageFromOrder(order);
    const updated = await this.orderReceiptRepository.updateDelivery(receipt.id, {
      messageText: freshMessage,
      paymentStatusSnapshot: order.paymentStatus,
      paymentMethodSnapshot:
        order.paymentStatus === OrderPaymentStatus.PAID
          ? order.paymentMethod
          : null,
      customerPhone: order.customer.phone,
      deliveryStatus: OrderReceiptDeliveryStatus.PENDING,
      failureReason: null,
      sentAt: null,
    });

    return {
      success: true,
      message: 'Manual WhatsApp handoff recorded',
      data: this.toResponse(
        updated.id,
        detail,
        updated.messageText,
        order,
        OrderReceiptDeliveryStatus.PENDING,
        null,
        null,
      ),
    };
  }

  async listDeliveries(orderId: string) {
    await this.requireOrder(orderId);
    const deliveries = await this.orderReceiptRepository.findByOrderId(orderId);

    return {
      success: true,
      message: 'Receipt deliveries retrieved successfully',
      data: deliveries.map((delivery) => ({
        id: delivery.id,
        orderId: delivery.orderId,
        deliveryStatus: delivery.deliveryStatus,
        deliveryChannel: delivery.deliveryChannel,
        paymentStatusSnapshot: delivery.paymentStatusSnapshot,
        paymentMethodSnapshot: delivery.paymentMethodSnapshot,
        customerPhone: delivery.customerPhone,
        failureReason: delivery.failureReason,
        sentAt: delivery.sentAt?.toISOString() ?? null,
        createdAt: delivery.createdAt.toISOString(),
      })),
    };
  }

  private async requireOrder(orderId: string) {
    const order = await this.orderRepository.findById(orderId);
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    return order;
  }

  private async buildMessageFromOrder(order: NonNullable<Awaited<ReturnType<OrderRepository['findById']>>>) {
    const company = await this.adminSettingsService.getCompanySettings();
    const { meta } = decodeOrderNotes(order.notes);
    const itemsSubtotal = order.items.reduce(
      (sum, item) => sum + Number(item.subtotal),
      0,
    );
    const totals = calculateOrderTotals(itemsSubtotal, meta);
    const latestPaidPayment = [...order.payments]
      .filter((payment) => payment.paymentStatus === 'PAID')
      .sort(
        (a, b) =>
          (b.paidAt?.getTime() ?? 0) - (a.paidAt?.getTime() ?? 0),
      )[0];

    const serviceLines = order.items.map((item) => {
      const qty =
        item.weight != null
          ? `${Number(item.weight)} Kg`
          : `${Number(item.quantity)} item`;
      return `${item.service.serviceName} · ${qty}`;
    });

    return buildOrderReceiptMessage({
      businessName: company.companyName || 'Yelo Laundry',
      orderNumber: order.invoiceNumber,
      customerName: order.customer.fullName,
      customerPhone: order.customer.phone,
      serviceLines,
      subtotal: totals.subtotal,
      tax: totals.tax,
      serviceFee: totals.serviceFee,
      grandTotal: totals.grandTotal,
      paymentStatus: order.paymentStatus,
      paymentMethod:
        order.paymentStatus === OrderPaymentStatus.PAID
          ? latestPaidPayment?.paymentMethod?.code ?? order.paymentMethod
          : null,
      paidAt:
        order.paymentStatus === OrderPaymentStatus.PAID
          ? latestPaidPayment?.paidAt ?? null
          : null,
    });
  }

  private toResponse(
    receiptId: string,
    detail: ReturnType<typeof toOrderListItem>,
    messageText: string,
    order: NonNullable<Awaited<ReturnType<OrderRepository['findById']>>>,
    deliveryStatus: OrderReceiptDeliveryStatus = OrderReceiptDeliveryStatus.PENDING,
    failureReason: string | null = null,
    sentAt: Date | null = null,
  ): OrderReceiptResponse {
    return {
      id: receiptId,
      orderId: detail.id,
      orderNumber: detail.orderNumber,
      customerName: detail.customerName,
      customerPhone: detail.customerPhone,
      messageText,
      paymentStatus: order.paymentStatus,
      paymentMethodLabel:
        order.paymentStatus === OrderPaymentStatus.PAID
          ? (order.paymentMethod ?? '-')
          : 'BAYAR NANTI',
      deliveryStatus,
      deliveryChannel: 'WHATSAPP',
      providerAvailable: this.whatsappProvider.isConfigured(),
      sentAt: sentAt?.toISOString() ?? null,
      failureReason,
      createdAt: new Date().toISOString(),
    };
  }
}
