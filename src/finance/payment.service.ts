import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { OrderStatus, PaymentStatus, WalletTransactionType } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerWalletRepository } from '../customer/customer-wallet.repository';
import { RewardService } from '../loyalty/reward.service';
import {
  API_NOTIFICATION_TYPES,
  NOTIFICATION_EVENTS,
} from '../notification/constants/notification.constants';
import { NotificationEventService } from '../notification/notification-event.service';
import { FinanceAuditService } from './finance-audit.service';
import { FinanceSettingsRepository } from './finance-settings.repository';
import {
  CreatePaymentDto,
  PaymentQueryDto,
  RefundPaymentDto,
  UpdatePaymentDto,
} from './dto/payment.dto';
import {
  buildPaymentMetaFromDto,
  PaginatedPayments,
  PaymentResponse,
  mapApiPaymentMethodToDbCode,
  toPaymentResponse,
} from './payment.mapper';
import { PaymentRepository } from './payment.repository';
import {
  decodePaymentNotes,
  encodePaymentNotes,
  getTotalRefunded,
} from './utils/payment-meta.util';

@Injectable()
export class PaymentService {
  constructor(
    private readonly paymentRepository: PaymentRepository,
    private readonly financeSettings: FinanceSettingsRepository,
    private readonly walletRepository: CustomerWalletRepository,
    private readonly auditService: FinanceAuditService,
    private readonly notificationEventService: NotificationEventService,
    private readonly rewardService: RewardService,
  ) {}

  async findAll(
    query: PaymentQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedPayments>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [payments, total] = await this.paymentRepository.findMany(query);

    const items = await Promise.all(
      payments.map(async (payment) => {
        const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
          payment.orderId,
        );

        return toPaymentResponse(payment, totalPaid);
      }),
    );

    return {
      success: true,
      message: 'Payments retrieved successfully',
      data: {
        items,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findOne(id: string): Promise<ApiSuccessResponse<PaymentResponse>> {
    const payment = await this.paymentRepository.findById(id);

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
      payment.orderId,
    );

    return {
      success: true,
      message: 'Payment retrieved successfully',
      data: toPaymentResponse(payment, totalPaid),
    };
  }

  async create(
    dto: CreatePaymentDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    const order = await this.paymentRepository.findOrderForPayment(dto.orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.orderStatus === OrderStatus.CANCELLED) {
      throw new BadRequestException('Cannot add payment to cancelled order');
    }

    const grandTotal = this.paymentRepository.getOrderGrandTotal(order);
    const paidTotal = order.payments
      .filter((payment) => payment.paymentStatus === PaymentStatus.PAID)
      .reduce((sum, payment) => sum + Number(payment.amount), 0);

    if (paidTotal + dto.amount > grandTotal) {
      throw new UnprocessableEntityException(
        'Payment amount exceeds order outstanding balance',
      );
    }

    const dbMethodCode = mapApiPaymentMethodToDbCode(dto.paymentMethod);
    const paymentMethod =
      await this.paymentRepository.findPaymentMethodByCode(dbMethodCode);

    if (!paymentMethod) {
      throw new BadRequestException('Payment method not found or inactive');
    }

    if (dto.voucherCode) {
      await this.validateVoucherForPayment(dto.voucherCode, grandTotal);
    }

    const referenceNumber =
      await this.financeSettings.generateReferenceNumber('PAY');

    const paymentStatus = dto.paymentStatus ?? PaymentStatus.PAID;

    if (
      dto.paymentMethod === 'CUSTOMER_WALLET' &&
      paymentStatus === PaymentStatus.PAID
    ) {
      const walletReferenceNumber =
        await this.walletRepository.generateNextReferenceNumber();

      const walletResult = await this.walletRepository.applyMutation({
        customerId: order.customerId,
        amount: dto.amount,
        type: WalletTransactionType.deduction,
        description: `Order payment ${referenceNumber}`,
        employeeId,
        referenceNumber: walletReferenceNumber,
        isCredit: false,
        referenceType: 'ORDER_PAYMENT',
        referenceId: dto.orderId,
      });

      if ('walletNotFound' in walletResult) {
        throw new NotFoundException('Customer wallet not found');
      }

      if ('insufficientBalance' in walletResult) {
        throw new UnprocessableEntityException('Insufficient wallet balance');
      }
    }

    const notes = encodePaymentNotes(
      buildPaymentMetaFromDto(dto),
      dto.notes,
    );

    let payment;

    try {
      payment = await this.paymentRepository.createPayment({
        orderId: dto.orderId,
        paymentMethodId: paymentMethod.id,
        amount: dto.amount,
        paymentStatus,
        referenceNumber,
        receivedByEmployeeId: employeeId,
        notes,
      });
    } catch (error) {
      if (error instanceof Error && error.message === 'DUPLICATE_PAYMENT') {
        throw new UnprocessableEntityException('Duplicate payment reference');
      }

      throw error;
    }

    if (dto.voucherCode) {
      await this.financeSettings.incrementVoucherUsage(dto.voucherCode);
    }

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'payment_created',
      referenceId: payment.id,
      description: `Payment ${referenceNumber} created for order ${order.invoiceNumber}`,
    });

    await this.notificationEventService.publish({
      templateCode:
        paymentStatus === PaymentStatus.PAID
          ? NOTIFICATION_EVENTS.PAYMENT_SUCCESS
          : NOTIFICATION_EVENTS.PAYMENT_FAILED,
      type: API_NOTIFICATION_TYPES.PAYMENT,
      eventKey: payment.id,
      senderEmployeeId: employeeId,
      orderId: order.id,
      orderNumber: order.invoiceNumber,
      customerId: order.customerId,
      amount: dto.amount,
      notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
      notifyCustomer: true,
    });

    const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
      payment.orderId,
    );

    return {
      success: true,
      message: 'Payment created successfully',
      data: toPaymentResponse(payment, totalPaid),
    };
  }

  async update(
    id: string,
    dto: UpdatePaymentDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    let payment;

    try {
      payment = await this.paymentRepository.updatePayment(
        id,
        {
          amount: dto.amount,
          paymentStatus: dto.paymentStatus,
          notes:
            dto.notes !== undefined
              ? encodePaymentNotes({}, dto.notes)
              : undefined,
        },
        employeeId,
      );
    } catch (error) {
      if (error instanceof Error) {
        if (error.message === 'NOT_FOUND') {
          throw new NotFoundException('Payment not found');
        }

        if (error.message === 'FINALIZED') {
          throw new BadRequestException('Cannot edit finalized payment');
        }
      }

      throw error;
    }

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'payment_updated',
      referenceId: payment.id,
      description: `Payment ${payment.referenceNumber ?? payment.id} updated`,
    });

    const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
      payment.orderId,
    );

    return {
      success: true,
      message: 'Payment updated successfully',
      data: toPaymentResponse(payment, totalPaid),
    };
  }

  async remove(
    id: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    let payment;

    try {
      payment = await this.paymentRepository.softDelete(id, employeeId);
    } catch (error) {
      if (error instanceof Error) {
        if (error.message === 'NOT_FOUND') {
          throw new NotFoundException('Payment not found');
        }

        if (error.message === 'FINALIZED') {
          throw new BadRequestException('Cannot void refunded payment');
        }
      }

      throw error;
    }

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'payment_voided',
      referenceId: payment.id,
      description: `Payment ${payment.referenceNumber ?? payment.id} voided`,
    });

    const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
      payment.orderId,
    );

    return {
      success: true,
      message: 'Payment voided successfully',
      data: toPaymentResponse(payment, totalPaid),
    };
  }

  async refund(
    id: string,
    dto: RefundPaymentDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    const payment = await this.paymentRepository.findById(id);

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (
      payment.paymentStatus === PaymentStatus.CANCELLED ||
      payment.paymentStatus === PaymentStatus.REFUNDED
    ) {
      throw new BadRequestException('Payment cannot be refunded');
    }

    const amount = Number(payment.amount);
    const { meta, notes } = decodePaymentNotes(payment.notes);
    const alreadyRefunded = getTotalRefunded(meta);

    if (alreadyRefunded + dto.amount > amount) {
      throw new UnprocessableEntityException(
        'Refund amount exceeds payment amount',
      );
    }

    const refundReference =
      await this.financeSettings.generateReferenceNumber('REF');

    const updatedMeta = {
      ...meta,
      refunds: [
        ...(meta.refunds ?? []),
        {
          referenceNumber: refundReference,
          amount: dto.amount,
          reason: dto.reason,
          refundedAt: new Date().toISOString(),
          refundedByEmployeeId: employeeId,
        },
      ],
    };

    const isFullRefund = alreadyRefunded + dto.amount >= amount;
    const updatedNotes = encodePaymentNotes(updatedMeta, notes);

    if (payment.paymentMethod.code === 'YELO_WALLET') {
      await this.walletRepository.applyMutation({
        customerId: payment.order.customerId,
        amount: dto.amount,
        type: WalletTransactionType.refund,
        description: `Payment refund ${refundReference}`,
        employeeId,
        referenceNumber: refundReference,
        isCredit: true,
      });
    }

    const updatedPayment = await this.paymentRepository.refundPayment(
      id,
      dto.amount,
      dto.reason,
      employeeId,
      refundReference,
      updatedNotes,
      isFullRefund,
    );

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'payment_refunded',
      referenceId: payment.id,
      description: `Refund ${refundReference} for payment ${payment.referenceNumber}`,
    });

    await this.notificationEventService.publish({
      templateCode: NOTIFICATION_EVENTS.REFUND_SUCCESS,
      type: API_NOTIFICATION_TYPES.FINANCE,
      eventKey: `${payment.id}:refund:${refundReference}`,
      senderEmployeeId: employeeId,
      orderId: payment.orderId,
      orderNumber: payment.order.invoiceNumber,
      customerId: payment.order.customerId,
      amount: dto.amount,
      notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
      notifyCustomer: true,
    });

    await this.rewardService.clawbackFromOrder(
      payment.order.customerId,
      payment.orderId,
      employeeId,
    );

    const totalPaid = await this.paymentRepository.getPaidTotalForOrder(
      payment.orderId,
    );

    return {
      success: true,
      message: isFullRefund
        ? 'Payment refunded successfully'
        : 'Partial refund processed successfully',
      data: toPaymentResponse(updatedPayment, totalPaid),
    };
  }

  private async validateVoucherForPayment(code: string, orderAmount: number) {
    const voucher = await this.financeSettings.getVoucher(code);

    if (!voucher || !voucher.isActive) {
      throw new BadRequestException('Voucher is invalid or inactive');
    }

    if (new Date(voucher.expiresAt) < new Date()) {
      throw new BadRequestException('Voucher has expired');
    }

    if (voucher.usedCount >= voucher.maxUsage) {
      throw new BadRequestException('Voucher usage limit reached');
    }

    if (orderAmount <= 0) {
      throw new BadRequestException('Order amount is required for voucher');
    }
  }
}
