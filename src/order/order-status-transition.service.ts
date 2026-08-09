import { BadRequestException, Injectable } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';

const TERMINAL_STATUSES: OrderStatus[] = [
  OrderStatus.COMPLETED,
  OrderStatus.CANCELLED,
];

const MANUAL_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  [OrderStatus.CREATED]: [
    OrderStatus.WAITING_PAYMENT,
    OrderStatus.PAYMENT_CONFIRMED,
    OrderStatus.WAITING_PICKUP_DRIVER,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.WAITING_PAYMENT]: [
    OrderStatus.PAYMENT_CONFIRMED,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.PAYMENT_CONFIRMED]: [
    OrderStatus.WAITING_BINATU,
    OrderStatus.WAITING_PICKUP_DRIVER,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.WAITING_BINATU]: [
    OrderStatus.IRONING_ACCEPTED,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.IRONING_ACCEPTED]: [
    OrderStatus.CURRENTLY_IRONING,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.CURRENTLY_IRONING]: [
    OrderStatus.FINISHED_IRONING,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.FINISHED_IRONING]: [
    OrderStatus.READY_FOR_PICKUP,
    OrderStatus.WAITING_DELIVERY,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.READY_FOR_PICKUP]: [
    OrderStatus.WAITING_DELIVERY,
    OrderStatus.OUT_FOR_DELIVERY,
    OrderStatus.COMPLETED,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.WAITING_PICKUP_DRIVER]: [
    OrderStatus.PICKUP_COMPLETED,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.PICKUP_COMPLETED]: [
    OrderStatus.PAYMENT_CONFIRMED,
    OrderStatus.WAITING_BINATU,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.WAITING_DELIVERY]: [
    OrderStatus.OUT_FOR_DELIVERY,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.OUT_FOR_DELIVERY]: [
    OrderStatus.DELIVERED,
    OrderStatus.CANCELLED,
  ],
  [OrderStatus.DELIVERED]: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
  [OrderStatus.COMPLETED]: [],
  [OrderStatus.CANCELLED]: [],
};

const OPERATIONAL_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  ...MANUAL_TRANSITIONS,
  [OrderStatus.CREATED]: [
    ...MANUAL_TRANSITIONS[OrderStatus.CREATED],
    OrderStatus.WAITING_BINATU,
  ],
  [OrderStatus.PAYMENT_CONFIRMED]: [
    ...MANUAL_TRANSITIONS[OrderStatus.PAYMENT_CONFIRMED],
    OrderStatus.CURRENTLY_IRONING,
    OrderStatus.FINISHED_IRONING,
    OrderStatus.READY_FOR_PICKUP,
  ],
  [OrderStatus.WAITING_BINATU]: [
    ...MANUAL_TRANSITIONS[OrderStatus.WAITING_BINATU],
    OrderStatus.CURRENTLY_IRONING,
    OrderStatus.FINISHED_IRONING,
    OrderStatus.READY_FOR_PICKUP,
  ],
  [OrderStatus.READY_FOR_PICKUP]: [
    ...MANUAL_TRANSITIONS[OrderStatus.READY_FOR_PICKUP],
    OrderStatus.DELIVERED,
  ],
};

@Injectable()
export class OrderStatusTransitionService {
  validateManualTransition(
    from: OrderStatus,
    to: OrderStatus,
  ): void {
    this.validateTransition(from, to, MANUAL_TRANSITIONS);
  }

  validateOperationalTransition(
    from: OrderStatus,
    to: OrderStatus,
  ): void {
    this.validateTransition(from, to, OPERATIONAL_TRANSITIONS);
  }

  resolveStatusAfterPayment(
    currentStatus: OrderStatus,
    options: { pickupRequired: boolean; isFullyPaid: boolean },
  ): OrderStatus | null {
    if (!options.isFullyPaid) {
      if (currentStatus === OrderStatus.CREATED) {
        return OrderStatus.WAITING_PAYMENT;
      }
      return null;
    }

    if (
      currentStatus !== OrderStatus.CREATED &&
      currentStatus !== OrderStatus.WAITING_PAYMENT
    ) {
      return null;
    }

    if (options.pickupRequired) {
      return OrderStatus.WAITING_PICKUP_DRIVER;
    }

    return OrderStatus.PAYMENT_CONFIRMED;
  }

  isTerminal(status: OrderStatus): boolean {
    return TERMINAL_STATUSES.includes(status);
  }

  private validateTransition(
    from: OrderStatus,
    to: OrderStatus,
    matrix: Record<OrderStatus, OrderStatus[]>,
  ): void {
    if (from === to) {
      throw new BadRequestException('Order is already in the requested status');
    }

    if (this.isTerminal(from)) {
      throw new BadRequestException(
        `Cannot transition from terminal status ${from}`,
      );
    }

    const allowed = matrix[from] ?? [];

    if (!allowed.includes(to)) {
      throw new BadRequestException(
        `Invalid order status transition from ${from} to ${to}`,
      );
    }
  }
}
