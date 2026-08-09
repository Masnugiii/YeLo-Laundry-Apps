import { BadRequestException } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { OrderStatusTransitionService } from '../../src/order/order-status-transition.service';

describe('OrderStatusTransitionService', () => {
  const service = new OrderStatusTransitionService();

  it('allows CREATED to WAITING_PAYMENT', () => {
    expect(() =>
      service.validateManualTransition(
        OrderStatus.CREATED,
        OrderStatus.WAITING_PAYMENT,
      ),
    ).not.toThrow();
  });

  it('rejects illegal jump from CREATED to COMPLETED', () => {
    expect(() =>
      service.validateManualTransition(
        OrderStatus.CREATED,
        OrderStatus.COMPLETED,
      ),
    ).toThrow(BadRequestException);
  });

  it('rejects transition from terminal status', () => {
    expect(() =>
      service.validateManualTransition(
        OrderStatus.COMPLETED,
        OrderStatus.CREATED,
      ),
    ).toThrow(BadRequestException);
  });

  it('resolves PAYMENT_CONFIRMED after full payment without pickup', () => {
    expect(
      service.resolveStatusAfterPayment(OrderStatus.CREATED, {
        pickupRequired: false,
        isFullyPaid: true,
      }),
    ).toBe(OrderStatus.PAYMENT_CONFIRMED);
  });

  it('resolves WAITING_PICKUP_DRIVER after full payment with pickup', () => {
    expect(
      service.resolveStatusAfterPayment(OrderStatus.WAITING_PAYMENT, {
        pickupRequired: true,
        isFullyPaid: true,
      }),
    ).toBe(OrderStatus.WAITING_PICKUP_DRIVER);
  });

  it('resolves WAITING_PAYMENT for partial payment from CREATED', () => {
    expect(
      service.resolveStatusAfterPayment(OrderStatus.CREATED, {
        pickupRequired: false,
        isFullyPaid: false,
      }),
    ).toBe(OrderStatus.WAITING_PAYMENT);
  });
});
