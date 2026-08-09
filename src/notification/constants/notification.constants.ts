export const NOTIFICATION_META_PREFIX = 'notification.delivery.';
export const NOTIFICATION_EMPLOYEE_INDEX_PREFIX = 'notification.employee.';
export const NOTIFICATION_CUSTOMER_INDEX_PREFIX = 'notification.customer.';
export const NOTIFICATION_EVENT_PREFIX = 'notification.event.';

export const NOTIFICATION_CHANNELS = {
  IN_APP: 'IN_APP',
  PUSH: 'PUSH',
  EMAIL: 'EMAIL',
  SMS: 'SMS',
} as const;

export type NotificationChannel =
  (typeof NOTIFICATION_CHANNELS)[keyof typeof NOTIFICATION_CHANNELS];

export const NOTIFICATION_STATUSES = {
  PENDING: 'PENDING',
  QUEUED: 'QUEUED',
  SENT: 'SENT',
  DELIVERED: 'DELIVERED',
  READ: 'READ',
  FAILED: 'FAILED',
} as const;

export type NotificationStatus =
  (typeof NOTIFICATION_STATUSES)[keyof typeof NOTIFICATION_STATUSES];

export const API_NOTIFICATION_TYPES = {
  SYSTEM: 'SYSTEM',
  ORDER: 'ORDER',
  PAYMENT: 'PAYMENT',
  FINANCE: 'FINANCE',
  CUSTOMER: 'CUSTOMER',
  EMPLOYEE: 'EMPLOYEE',
  ATTENDANCE: 'ATTENDANCE',
  PICKUP: 'PICKUP',
  DELIVERY: 'DELIVERY',
  LAUNDRY: 'LAUNDRY',
  PROMOTION: 'PROMOTION',
} as const;

export type ApiNotificationType =
  (typeof API_NOTIFICATION_TYPES)[keyof typeof API_NOTIFICATION_TYPES];

export const API_NOTIFICATION_PRIORITIES = {
  LOW: 'LOW',
  NORMAL: 'NORMAL',
  HIGH: 'HIGH',
  CRITICAL: 'CRITICAL',
} as const;

export type ApiNotificationPriority =
  (typeof API_NOTIFICATION_PRIORITIES)[keyof typeof API_NOTIFICATION_PRIORITIES];

export const NOTIFICATION_EVENTS = {
  ORDER_CREATED: 'order.created',
  ORDER_CANCELLED: 'order.cancelled',
  PAYMENT_SUCCESS: 'payment.success',
  PAYMENT_FAILED: 'payment.failed',
  REFUND_SUCCESS: 'refund.success',
  LAUNDRY_STARTED: 'laundry.started',
  LAUNDRY_FINISHED: 'laundry.finished',
  READY_FOR_PICKUP: 'pickup.ready',
  DRIVER_ASSIGNED: 'driver.assigned',
  DRIVER_STARTED: 'driver.started',
  PICKUP_COMPLETED: 'pickup.completed',
  DELIVERY_COMPLETED: 'delivery.completed',
  PICKUP_REQUESTED: 'pickup.requested',
  DRIVER_ON_THE_WAY: 'driver.on_the_way',
  DELIVERY_STARTED: 'delivery.started',
  ATTENDANCE_LATE: 'attendance.late',
  LEAVE_APPROVED: 'leave.approved',
  LEAVE_REJECTED: 'leave.rejected',
  WALLET_TOPUP: 'wallet.topup',
  WALLET_DEDUCTION: 'wallet.deduction',
  PROMOTION: 'promotion',
} as const;

export type NotificationEventKey =
  (typeof NOTIFICATION_EVENTS)[keyof typeof NOTIFICATION_EVENTS];

export const TEMPLATE_VARIABLES = [
  'customerName',
  'orderNumber',
  'amount',
  'driverName',
  'estimatedTime',
] as const;

export type TemplateVariable = (typeof TEMPLATE_VARIABLES)[number];
