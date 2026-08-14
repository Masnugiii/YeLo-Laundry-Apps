import { OrderPaymentStatus } from '@prisma/client';
import { OrderReceiptMessageInput } from './order-receipt.types';

function formatCurrency(amount: number): string {
  return `Rp${Math.round(amount).toLocaleString('id-ID')}`;
}

function formatPaymentMethod(method: string | null, paymentStatus: OrderPaymentStatus): string {
  if (paymentStatus === OrderPaymentStatus.UNPAID) {
    return 'BAYAR NANTI';
  }

  if (!method) {
    return '-';
  }

  return method
    .replace(/_/g, ' ')
    .replace('CUSTOMER WALLET', 'YELO WALLET')
    .replace('BANK TRANSFER', 'TRANSFER');
}

function formatPaymentStatusLabel(paymentStatus: OrderPaymentStatus): string {
  return paymentStatus === OrderPaymentStatus.PAID ? 'LUNAS' : 'BELUM DIBAYAR';
}

export function buildOrderReceiptMessage(input: OrderReceiptMessageInput): string {
  const lines = [
    input.businessName.toUpperCase(),
    '',
    `Order:`,
    input.orderNumber,
    '',
    `Customer:`,
    input.customerName,
    '',
    `Layanan:`,
    ...input.serviceLines.map((line) => `- ${line}`),
    '',
    `Subtotal:`,
    formatCurrency(input.subtotal),
    '',
    `Tax:`,
    formatCurrency(input.tax),
    '',
    `Service Fee:`,
    formatCurrency(input.serviceFee),
    '',
    `TOTAL:`,
    formatCurrency(input.grandTotal),
    '',
    `STATUS PEMBAYARAN:`,
    formatPaymentStatusLabel(input.paymentStatus),
    '',
    `METODE:`,
    formatPaymentMethod(input.paymentMethod, input.paymentStatus),
  ];

  if (input.paymentStatus === OrderPaymentStatus.PAID && input.paidAt) {
    lines.push(
      '',
      `Paid At:`,
      input.paidAt.toLocaleString('id-ID', {
        timeZone: 'Asia/Jakarta',
        dateStyle: 'medium',
        timeStyle: 'short',
      }),
    );
  }

  return lines.join('\n');
}
