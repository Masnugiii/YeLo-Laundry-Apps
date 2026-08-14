import { OrderPaymentStatus } from '@prisma/client';

export type WhatsappSendResult =
  | { status: 'SENT'; sentAt: Date }
  | { status: 'NOT_CONFIGURED'; reason: string }
  | { status: 'FAILED'; reason: string };

export interface WhatsappProvider {
  isConfigured(): boolean;
  sendMessage(phone: string, message: string): Promise<WhatsappSendResult>;
}

export interface OrderReceiptMessageInput {
  businessName: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string | null;
  serviceLines: string[];
  subtotal: number;
  tax: number;
  serviceFee: number;
  grandTotal: number;
  paymentStatus: OrderPaymentStatus;
  paymentMethod: string | null;
  paidAt: Date | null;
}

export interface OrderReceiptResponse {
  id: string;
  orderId: string;
  orderNumber: string;
  customerName: string;
  customerPhone: string | null;
  messageText: string;
  paymentStatus: OrderPaymentStatus;
  paymentMethodLabel: string;
  deliveryStatus: string;
  deliveryChannel: string;
  providerAvailable: boolean;
  sentAt: string | null;
  failureReason: string | null;
  createdAt: string;
}
