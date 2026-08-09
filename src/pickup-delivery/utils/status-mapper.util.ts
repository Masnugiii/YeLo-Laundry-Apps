import { DeliveryStatus, PickupStatus } from '@prisma/client';
import { ApiDeliveryStatus, ApiPickupStatus } from './job-meta.util';

export function mapPickupStatusToApi(
  status: PickupStatus,
  displayStatus?: string,
): ApiPickupStatus {
  if (displayStatus) {
    return displayStatus as ApiPickupStatus;
  }

  switch (status) {
    case PickupStatus.WAITING_ASSIGNMENT:
      return 'REQUESTED';
    case PickupStatus.ASSIGNED:
    case PickupStatus.ACCEPTED:
      return 'ASSIGNED';
    case PickupStatus.ON_THE_WAY:
      return 'ON_THE_WAY';
    case PickupStatus.ARRIVED:
      return 'ARRIVED';
    case PickupStatus.COMPLETED:
      return 'PICKED_UP';
    default:
      return 'REQUESTED';
  }
}

export function mapDeliveryStatusToApi(
  status: DeliveryStatus,
  displayStatus?: string,
): ApiDeliveryStatus {
  if (displayStatus) {
    return displayStatus as ApiDeliveryStatus;
  }

  switch (status) {
    case DeliveryStatus.WAITING_ASSIGNMENT:
      return 'WAITING';
    case DeliveryStatus.ASSIGNED:
    case DeliveryStatus.ACCEPTED:
      return 'ASSIGNED';
    case DeliveryStatus.OUT_FOR_DELIVERY:
      return 'ON_THE_WAY';
    case DeliveryStatus.ARRIVED:
      return 'ARRIVED';
    case DeliveryStatus.COMPLETED:
      return 'DELIVERED';
    case DeliveryStatus.FAILED:
      return 'FAILED';
    default:
      return 'WAITING';
  }
}

export const ACTIVE_PICKUP_STATUSES: PickupStatus[] = [
  PickupStatus.ASSIGNED,
  PickupStatus.ACCEPTED,
  PickupStatus.ON_THE_WAY,
  PickupStatus.ARRIVED,
];

export const ACTIVE_DELIVERY_STATUSES: DeliveryStatus[] = [
  DeliveryStatus.ASSIGNED,
  DeliveryStatus.ACCEPTED,
  DeliveryStatus.OUT_FOR_DELIVERY,
  DeliveryStatus.ARRIVED,
];
