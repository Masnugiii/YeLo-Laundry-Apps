import { Decimal } from '@prisma/client/runtime/library';
import { PaymentStatus } from '@prisma/client';
import {
  calculateOrderTotals,
} from '../order/order.mapper';
import { decodeOrderNotes } from '../order/utils/order-meta.util';
import {
  decodePaymentNotes,
  getTotalRefunded,
  PaymentFinancialMeta,
} from './utils/payment-meta.util';
import { PaymentDetailRecord, PaymentListRecord } from './payment.select';

export interface PaymentResponse {
  id: string;
  referenceNumber: string | null;
  orderId: string;
  orderNumber: string;
  queueNumber: string;
  customer: {
    id: string;
    customerCode: string;
    fullName: string;
    phone: string;
  };
  paymentMethod: {
    id: string;
    code: string;
    name: string;
    apiCode: string | null;
  };
  amount: number;
  refundedAmount: number;
  netAmount: number;
  paymentStatus: PaymentStatus;
  displayStatus: string;
  paidAt: Date;
  notes: string | null;
  discount: {
    type: string | null;
    value: number | null;
    voucherCode: string | null;
  };
  receivedBy: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  refundHistory: Array<{
    referenceNumber: string;
    amount: number;
    reason: string;
    refundedAt: string;
  }>;
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedPayments {
  items: PaymentResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

function decimalToNumber(value: Decimal | number | null | undefined): number {
  if (value === null || value === undefined) {
    return 0;
  }

  return Number(value);
}

export function getOrderGrandTotal(
  order: PaymentListRecord['order'],
): number {
  const { meta } = decodeOrderNotes(order.notes);
  const itemsSubtotal = order.items.reduce(
    (sum, item) => sum + decimalToNumber(item.subtotal),
    0,
  );

  return calculateOrderTotals(itemsSubtotal, meta).grandTotal;
}

export function mapApiPaymentMethodToDbCode(apiMethod: string): string {
  switch (apiMethod) {
    case 'CUSTOMER_WALLET':
      return 'YELO_WALLET';
    case 'DEBIT_CARD':
    case 'CREDIT_CARD':
      return 'BANK_TRANSFER';
    case 'EWALLET':
      return 'QRIS';
    default:
      return apiMethod;
  }
}

export function resolveDisplayStatus(
  payment: PaymentListRecord,
  grandTotal: number,
  totalPaidOnOrder: number,
): string {
  if (payment.paymentStatus === PaymentStatus.CANCELLED) {
    return 'VOID';
  }

  if (payment.paymentStatus === PaymentStatus.REFUNDED) {
    return 'REFUNDED';
  }

  if (
    payment.paymentStatus === PaymentStatus.PAID &&
    totalPaidOnOrder > 0 &&
    totalPaidOnOrder < grandTotal
  ) {
    return 'PARTIAL';
  }

  return payment.paymentStatus;
}

export function toPaymentResponse(
  payment: PaymentListRecord | PaymentDetailRecord,
  totalPaidOnOrder = decimalToNumber(payment.amount),
): PaymentResponse {
  const { meta, notes } = decodePaymentNotes(payment.notes);
  const refundedAmount = getTotalRefunded(meta);
  const amount = decimalToNumber(payment.amount);
  const grandTotal = getOrderGrandTotal(payment.order);

  return {
    id: payment.id,
    referenceNumber: payment.referenceNumber,
    orderId: payment.orderId,
    orderNumber: payment.order.invoiceNumber,
    queueNumber: payment.order.queueNumber,
    customer: payment.order.customer,
    paymentMethod: {
      id: payment.paymentMethod.id,
      code: payment.paymentMethod.code,
      name: payment.paymentMethod.name,
      apiCode: meta.apiPaymentMethod ?? payment.paymentMethod.code,
    },
    amount,
    refundedAmount,
    netAmount: Number((amount - refundedAmount).toFixed(2)),
    paymentStatus: payment.paymentStatus,
    displayStatus: resolveDisplayStatus(payment, grandTotal, totalPaidOnOrder),
    paidAt: payment.paidAt,
    notes,
    discount: {
      type: meta.discountType ?? null,
      value: meta.discountValue ?? null,
      voucherCode: meta.voucherCode ?? null,
    },
    receivedBy: payment.receivedByEmployee,
    refundHistory: (meta.refunds ?? []).map((entry) => ({
      referenceNumber: entry.referenceNumber,
      amount: entry.amount,
      reason: entry.reason,
      refundedAt: entry.refundedAt,
    })),
    createdAt: payment.createdAt,
    updatedAt: payment.updatedAt,
  };
}

export function buildPaymentMetaFromDto(dto: {
  paymentMethod: string;
  discountType?: string;
  discountValue?: number;
  voucherCode?: string;
}): PaymentFinancialMeta {
  return {
    apiPaymentMethod: dto.paymentMethod,
    discountType: dto.discountType as PaymentFinancialMeta['discountType'],
    discountValue: dto.discountValue,
    voucherCode: dto.voucherCode,
  };
}
