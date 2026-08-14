import { OrderStatus } from '@prisma/client';
import { NOTIFICATION_EVENTS } from '../../src/notification/constants/notification.constants';
import {
  buildStatusNotificationDedupKey,
  resolveOrderStatusNotification,
} from '../../src/order/utils/order-status-notification.util';

describe('order-status-notification.util', () => {
  it('maps ironing accepted to laundry started', () => {
    const config = resolveOrderStatusNotification(
      OrderStatus.IRONING_ACCEPTED,
    );

    expect(config?.templateCode).toBe(NOTIFICATION_EVENTS.LAUNDRY_STARTED);
    expect(config?.notifyCustomer).toBe(true);
  });

  it('maps finished ironing to laundry finished', () => {
    const config = resolveOrderStatusNotification(
      OrderStatus.FINISHED_IRONING,
    );

    expect(config?.templateCode).toBe(NOTIFICATION_EVENTS.LAUNDRY_FINISHED);
  });

  it('maps ready for pickup to pickup ready template', () => {
    const config = resolveOrderStatusNotification(OrderStatus.READY_FOR_PICKUP);

    expect(config?.templateCode).toBe(NOTIFICATION_EVENTS.READY_FOR_PICKUP);
  });

  it('does not map payment confirmed', () => {
    expect(
      resolveOrderStatusNotification(OrderStatus.PAYMENT_CONFIRMED),
    ).toBeNull();
  });

  it('builds stable deduplication keys per order and template', () => {
    const orderId = '660e8400-e29b-41d4-a716-446655440001';

    expect(
      buildStatusNotificationDedupKey(
        NOTIFICATION_EVENTS.LAUNDRY_STARTED,
        orderId,
      ),
    ).toBe(`laundry.started:${orderId}`);
  });
});
