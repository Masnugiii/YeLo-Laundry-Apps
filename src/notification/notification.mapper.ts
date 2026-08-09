import { NotificationListRecord } from './notification.select';
import { NotificationDeliveryMeta } from './utils/notification-meta.util';
import {
  ApiNotificationPriority,
  ApiNotificationType,
  NotificationChannel,
  NotificationStatus,
} from './constants/notification.constants';
import {
  mapPrismaPriorityToApi,
  mapPrismaTypeToApi,
} from './utils/notification-type.util';

export interface NotificationResponse {
  id: string;
  title: string;
  message: string;
  type: ApiNotificationType;
  priority: ApiNotificationPriority;
  status: NotificationStatus;
  channels: NotificationChannel[];
  isRead: boolean;
  recipientType?: 'EMPLOYEE' | 'CUSTOMER';
  recipientEmployeeId?: string;
  recipientCustomerId?: string;
  recipientName?: string;
  orderId?: string;
  orderNumber?: string;
  customerName?: string;
  createdBy?: {
    id: string;
    fullName: string;
    employeeCode: string;
  };
  sentAt?: string;
  readAt?: string;
  createdAt: string;
}

export interface PaginatedNotifications {
  items: NotificationResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface NotificationDashboard {
  unreadCount: number;
  todayNotifications: number;
  failedNotifications: number;
  pendingQueue: number;
  sentToday: number;
  readToday: number;
}

export function toNotificationResponse(
  record: NotificationListRecord,
  meta: NotificationDeliveryMeta | null,
  options: {
    isRead: boolean;
    readAt?: string;
  },
): NotificationResponse {
  return {
    id: record.id,
    title: record.title,
    message: record.body,
    type: mapPrismaTypeToApi(record.type),
    priority: mapPrismaPriorityToApi(record.priority),
    status: meta?.status ?? 'SENT',
    channels: meta?.channels ?? ['IN_APP'],
    isRead: options.isRead,
    recipientType: meta?.recipientType,
    recipientEmployeeId: meta?.recipientEmployeeId,
    recipientCustomerId: meta?.recipientCustomerId,
    recipientName: meta?.recipientName,
    orderId: meta?.orderId,
    orderNumber: meta?.orderNumber,
    customerName: meta?.customerName,
    createdBy: record.senderEmployee
      ? {
          id: record.senderEmployee.id,
          fullName: record.senderEmployee.fullName,
          employeeCode: record.senderEmployee.employeeCode,
        }
      : undefined,
    sentAt: meta?.sentAt,
    readAt: options.readAt ?? meta?.readAt,
    createdAt: record.createdAt.toISOString(),
  };
}
