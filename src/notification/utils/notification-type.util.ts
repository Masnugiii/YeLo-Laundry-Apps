import { NotificationType, PriorityLevel } from '@prisma/client';
import {
  API_NOTIFICATION_PRIORITIES,
  API_NOTIFICATION_TYPES,
  ApiNotificationPriority,
  ApiNotificationType,
} from '../constants/notification.constants';

const API_TO_PRISMA_TYPE: Record<ApiNotificationType, NotificationType> = {
  [API_NOTIFICATION_TYPES.SYSTEM]: NotificationType.SYSTEM,
  [API_NOTIFICATION_TYPES.ORDER]: NotificationType.ORDER,
  [API_NOTIFICATION_TYPES.PAYMENT]: NotificationType.PAYMENT,
  [API_NOTIFICATION_TYPES.FINANCE]: NotificationType.PAYMENT,
  [API_NOTIFICATION_TYPES.CUSTOMER]: NotificationType.CUSTOMER_SERVICE,
  [API_NOTIFICATION_TYPES.EMPLOYEE]: NotificationType.SYSTEM,
  [API_NOTIFICATION_TYPES.ATTENDANCE]: NotificationType.SYSTEM,
  [API_NOTIFICATION_TYPES.PICKUP]: NotificationType.PICKUP,
  [API_NOTIFICATION_TYPES.DELIVERY]: NotificationType.DELIVERY,
  [API_NOTIFICATION_TYPES.LAUNDRY]: NotificationType.IRONING,
  [API_NOTIFICATION_TYPES.PROMOTION]: NotificationType.SYSTEM,
};

const PRISMA_TO_API_TYPE: Record<NotificationType, ApiNotificationType> = {
  [NotificationType.SYSTEM]: API_NOTIFICATION_TYPES.SYSTEM,
  [NotificationType.ORDER]: API_NOTIFICATION_TYPES.ORDER,
  [NotificationType.PAYMENT]: API_NOTIFICATION_TYPES.PAYMENT,
  [NotificationType.IRONING]: API_NOTIFICATION_TYPES.LAUNDRY,
  [NotificationType.PICKUP]: API_NOTIFICATION_TYPES.PICKUP,
  [NotificationType.DELIVERY]: API_NOTIFICATION_TYPES.DELIVERY,
  [NotificationType.CUSTOMER_SERVICE]: API_NOTIFICATION_TYPES.CUSTOMER,
};

const API_TO_PRISMA_PRIORITY: Record<ApiNotificationPriority, PriorityLevel> = {
  [API_NOTIFICATION_PRIORITIES.LOW]: PriorityLevel.LOW,
  [API_NOTIFICATION_PRIORITIES.NORMAL]: PriorityLevel.NORMAL,
  [API_NOTIFICATION_PRIORITIES.HIGH]: PriorityLevel.HIGH,
  [API_NOTIFICATION_PRIORITIES.CRITICAL]: PriorityLevel.URGENT,
};

const PRISMA_TO_API_PRIORITY: Record<PriorityLevel, ApiNotificationPriority> = {
  [PriorityLevel.LOW]: API_NOTIFICATION_PRIORITIES.LOW,
  [PriorityLevel.NORMAL]: API_NOTIFICATION_PRIORITIES.NORMAL,
  [PriorityLevel.HIGH]: API_NOTIFICATION_PRIORITIES.HIGH,
  [PriorityLevel.URGENT]: API_NOTIFICATION_PRIORITIES.CRITICAL,
};

export function mapApiTypeToPrisma(type: ApiNotificationType): NotificationType {
  return API_TO_PRISMA_TYPE[type] ?? NotificationType.SYSTEM;
}

export function mapPrismaTypeToApi(type: NotificationType): ApiNotificationType {
  return PRISMA_TO_API_TYPE[type] ?? API_NOTIFICATION_TYPES.SYSTEM;
}

export function mapApiPriorityToPrisma(
  priority: ApiNotificationPriority,
): PriorityLevel {
  return API_TO_PRISMA_PRIORITY[priority] ?? PriorityLevel.NORMAL;
}

export function mapPrismaPriorityToApi(
  priority: PriorityLevel,
): ApiNotificationPriority {
  return PRISMA_TO_API_PRIORITY[priority] ?? API_NOTIFICATION_PRIORITIES.NORMAL;
}
