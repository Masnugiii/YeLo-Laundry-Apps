import { OrderStatus } from '@prisma/client';
import { ProductionStatus } from './production-meta.util';

export function mapProductionStageToOrderStatus(
  stage: ProductionStatus,
): OrderStatus {
  switch (stage) {
    case 'WAITING_IRON':
      return OrderStatus.WAITING_BINATU;
    case 'IRONING':
      return OrderStatus.CURRENTLY_IRONING;
    case 'QUALITY_CHECK':
      return OrderStatus.FINISHED_IRONING;
    case 'READY':
      return OrderStatus.READY_FOR_PICKUP;
    case 'COMPLETED':
      return OrderStatus.COMPLETED;
    default:
      return OrderStatus.PAYMENT_CONFIRMED;
  }
}

export function inferProductionStageFromOrderStatus(
  orderStatus: OrderStatus,
  currentStage?: ProductionStatus,
): ProductionStatus {
  if (currentStage) {
    return currentStage;
  }

  switch (orderStatus) {
    case OrderStatus.WAITING_BINATU:
      return 'WAITING_IRON';
    case OrderStatus.IRONING_ACCEPTED:
    case OrderStatus.CURRENTLY_IRONING:
      return 'IRONING';
    case OrderStatus.FINISHED_IRONING:
      return 'QUALITY_CHECK';
    case OrderStatus.READY_FOR_PICKUP:
      return 'READY';
    case OrderStatus.COMPLETED:
    case OrderStatus.DELIVERED:
      return 'COMPLETED';
    default:
      return 'WAITING_WASH';
  }
}

export const TERMINAL_ORDER_STATUSES: OrderStatus[] = [
  OrderStatus.CANCELLED,
  OrderStatus.COMPLETED,
  OrderStatus.DELIVERED,
];

export const PRODUCTION_ELIGIBLE_STATUSES: OrderStatus[] = [
  OrderStatus.CREATED,
  OrderStatus.WAITING_PAYMENT,
  OrderStatus.PAYMENT_CONFIRMED,
  OrderStatus.WAITING_BINATU,
  OrderStatus.IRONING_ACCEPTED,
  OrderStatus.CURRENTLY_IRONING,
  OrderStatus.FINISHED_IRONING,
  OrderStatus.READY_FOR_PICKUP,
];
