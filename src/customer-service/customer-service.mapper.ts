import { OrderStatus, SenderType, TicketStatus } from '@prisma/client';
import {
  categoryConfidence,
  CsCategory,
  parseCategory,
  stripCategoryPrefix,
} from './utils/category.util';
import { TicketDetailRecord, TicketListRecord } from './customer-service.select';

export interface CsSummary {
  unreadMessages: number;
  newComplaints: number;
  orderQuestions: number;
  completed: number;
}

export interface CsMessageResponse {
  id: string;
  senderType: SenderType;
  content: string;
  createdAt: string;
  isFromCustomer: boolean;
  employeeName?: string;
}

export interface CsRelatedOrder {
  queueNumber: string;
  laundryService: string;
  currentStatus: string;
  estimatedCompletion: string | null;
}

export interface CsTicketListItem {
  id: string;
  customerId: string;
  customerName: string;
  whatsappNumber: string;
  subject: string;
  messagePreview: string;
  messageTime: string;
  category: CsCategory;
  aiConfidence: number;
  isUnread: boolean;
  status: TicketStatus;
  priority: string;
}

export interface CsTicketDetail extends CsTicketListItem {
  aiSummary: string;
  messages: CsMessageResponse[];
  relatedOrder: CsRelatedOrder | null;
  assigneeName?: string;
}

const ORDER_STATUS_LABELS: Record<OrderStatus, string> = {
  CREATED: 'Dibuat',
  WAITING_PAYMENT: 'Menunggu Pembayaran',
  PAYMENT_CONFIRMED: 'Pembayaran Dikonfirmasi',
  WAITING_BINATU: 'Menunggu Binatu',
  IRONING_ACCEPTED: 'Disetrika',
  CURRENTLY_IRONING: 'Sedang Disetrika',
  FINISHED_IRONING: 'Selesai Disetrika',
  READY_FOR_PICKUP: 'Siap Diambil',
  WAITING_PICKUP_DRIVER: 'Menunggu Driver Pickup',
  PICKUP_COMPLETED: 'Pickup Selesai',
  WAITING_DELIVERY: 'Menunggu Pengiriman',
  OUT_FOR_DELIVERY: 'Dalam Pengiriman',
  DELIVERED: 'Terkirim',
  COMPLETED: 'Selesai',
  CANCELLED: 'Dibatalkan',
};

function isUnreadStatus(status: TicketStatus): boolean {
  return status === TicketStatus.OPEN || status === TicketStatus.IN_PROGRESS;
}

function buildAiSummary(preview: string): string {
  if (!preview) {
    return 'Belum ada pesan pada tiket ini.';
  }
  return `Pesan terbaru: ${preview}`;
}

export function toTicketListItem(ticket: TicketListRecord): CsTicketListItem {
  const latestMessage = ticket.messages[0];
  const category = parseCategory(ticket.subject);
  const preview = latestMessage?.message ?? stripCategoryPrefix(ticket.subject);

  return {
    id: ticket.id,
    customerId: ticket.customer.id,
    customerName: ticket.customer.fullName,
    whatsappNumber: ticket.customer.phone,
    subject: stripCategoryPrefix(ticket.subject),
    messagePreview: preview,
    messageTime: (latestMessage?.createdAt ?? ticket.updatedAt).toISOString(),
    category,
    aiConfidence: categoryConfidence(category),
    isUnread: isUnreadStatus(ticket.status),
    status: ticket.status,
    priority: ticket.priority,
  };
}

export function toTicketDetail(
  ticket: TicketDetailRecord,
  relatedOrder: CsRelatedOrder | null,
): CsTicketDetail {
  const listItem = toTicketListItem({
    ...ticket,
    messages: ticket.messages.length
      ? [ticket.messages[ticket.messages.length - 1]]
      : [],
  });

  return {
    ...listItem,
    aiSummary: buildAiSummary(listItem.messagePreview),
    assigneeName: ticket.employee?.fullName,
    relatedOrder,
    messages: ticket.messages.map((message) => ({
      id: message.id,
      senderType: message.senderType,
      content: message.message,
      createdAt: message.createdAt.toISOString(),
      isFromCustomer: message.senderType === SenderType.CUSTOMER,
      employeeName: message.employee?.fullName,
    })),
  };
}

export function mapOrderStatus(status: OrderStatus): string {
  return ORDER_STATUS_LABELS[status] ?? status;
}
