import {
  NOTIFICATION_CUSTOMER_INDEX_PREFIX,
  NOTIFICATION_EMPLOYEE_INDEX_PREFIX,
  NOTIFICATION_EVENT_PREFIX,
  NOTIFICATION_META_PREFIX,
  NotificationChannel,
  NotificationStatus,
} from '../constants/notification.constants';

export type RecipientType = 'EMPLOYEE' | 'CUSTOMER';

export interface ChannelDispatchLog {
  channel: NotificationChannel;
  status: NotificationStatus;
  attemptedAt: string;
  completedAt?: string;
  errorMessage?: string;
}

export interface NotificationDeliveryMeta {
  notificationId: string;
  channels: NotificationChannel[];
  status: NotificationStatus;
  recipientType: RecipientType;
  recipientEmployeeId?: string;
  recipientCustomerId?: string;
  recipientName?: string;
  recipientPhone?: string;
  recipientEmail?: string;
  orderId?: string;
  orderNumber?: string;
  customerName?: string;
  eventKey?: string;
  templateCode?: string;
  createdByEmployeeId?: string;
  sentAt?: string;
  readAt?: string;
  deletedAt?: string;
  dispatchLog: ChannelDispatchLog[];
}

export function buildMetaSettingKey(notificationId: string): string {
  return `${NOTIFICATION_META_PREFIX}${notificationId}`;
}

export function buildEmployeeIndexKey(
  employeeId: string,
  notificationId: string,
): string {
  return `${NOTIFICATION_EMPLOYEE_INDEX_PREFIX}${employeeId}.${notificationId}`;
}

export function buildCustomerIndexKey(
  customerId: string,
  notificationId: string,
): string {
  return `${NOTIFICATION_CUSTOMER_INDEX_PREFIX}${customerId}.${notificationId}`;
}

export function buildEventDedupKey(eventKey: string): string {
  return `${NOTIFICATION_EVENT_PREFIX}${eventKey}`;
}

export function parseNotificationMeta(raw: string): NotificationDeliveryMeta | null {
  try {
    return JSON.parse(raw) as NotificationDeliveryMeta;
  } catch {
    return null;
  }
}

export function encodeNotificationMeta(meta: NotificationDeliveryMeta): string {
  return JSON.stringify(meta);
}

export function extractNotificationIdFromIndexKey(
  prefix: string,
  settingKey: string,
): string | null {
  if (!settingKey.startsWith(prefix)) {
    return null;
  }

  const remainder = settingKey.slice(prefix.length);
  const dotIndex = remainder.indexOf('.');

  if (dotIndex === -1) {
    return null;
  }

  return remainder.slice(dotIndex + 1);
}
