export type OrderReceiptDeliveryStatus =
  | "PENDING"
  | "SENT"
  | "FAILED"
  | "NOT_CONFIGURED";

export interface OrderReceiptDelivery {
  id: string;
  orderId: string;
  deliveryStatus: OrderReceiptDeliveryStatus;
  deliveryChannel: string;
  paymentStatusSnapshot: string;
  paymentMethodSnapshot: string | null;
  customerPhone: string | null;
  failureReason: string | null;
  sentAt: string | null;
  createdAt: string;
}
