import { OrderStatus } from '@prisma/client';
import {
  API_NOTIFICATION_TYPES,
  ApiNotificationType,
  NOTIFICATION_EVENTS,
  NotificationEventKey,
} from '../../notification/constants/notification.constants';

export interface OrderStatusNotificationConfig {
  templateCode: NotificationEventKey;
  type: ApiNotificationType;
  notifyRoles?: string[];
  notifyCustomer: boolean;
}

const LIFECYCLE_STATUS_NOTIFICATIONS: Partial<
  Record<OrderStatus, OrderStatusNotificationConfig>
> = {
  [OrderStatus.IRONING_ACCEPTED]: {
    templateCode: NOTIFICATION_EVENTS.LAUNDRY_STARTED,
    type: API_NOTIFICATION_TYPES.LAUNDRY,
    notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
    notifyCustomer: true,
  },
  [OrderStatus.FINISHED_IRONING]: {
    templateCode: NOTIFICATION_EVENTS.LAUNDRY_FINISHED,
    type: API_NOTIFICATION_TYPES.LAUNDRY,
    notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
    notifyCustomer: true,
  },
  [OrderStatus.READY_FOR_PICKUP]: {
    templateCode: NOTIFICATION_EVENTS.READY_FOR_PICKUP,
    type: API_NOTIFICATION_TYPES.DELIVERY,
    notifyRoles: ['OWNER', 'MANAGER', 'DRIVER'],
    notifyCustomer: true,
  },
  [OrderStatus.OUT_FOR_DELIVERY]: {
    templateCode: NOTIFICATION_EVENTS.DELIVERY_STARTED,
    type: API_NOTIFICATION_TYPES.DELIVERY,
    notifyCustomer: true,
  },
  [OrderStatus.DELIVERED]: {
    templateCode: NOTIFICATION_EVENTS.DELIVERY_COMPLETED,
    type: API_NOTIFICATION_TYPES.DELIVERY,
    notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
    notifyCustomer: true,
  },
};

export function resolveOrderStatusNotification(
  status: OrderStatus,
): OrderStatusNotificationConfig | null {
  return LIFECYCLE_STATUS_NOTIFICATIONS[status] ?? null;
}

export function buildStatusNotificationDedupKey(
  templateCode: string,
  orderId: string,
): string {
  return `${templateCode}:${orderId}`;
}
