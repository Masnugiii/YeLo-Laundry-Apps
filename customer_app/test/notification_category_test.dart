import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/utils/notification_category.dart';

AppNotification _notification({
  required String type,
  required String title,
  String message = '',
  String createdAt = '2026-08-10T10:00:00.000Z',
}) {
  return AppNotification(
    id: 'test',
    title: title,
    message: message,
    type: type,
    createdAt: createdAt,
    isRead: false,
  );
}

void main() {
  group('resolveNotificationCategory', () {
    test('maps order.created style notifications to Pesanan', () {
      expect(
        resolveNotificationCategory(_notification(type: 'ORDER', title: 'Order Created')),
        NotificationCategory.order,
      );
    });

    test('maps payment.success to Pembayaran', () {
      expect(
        resolveNotificationCategory(
          _notification(type: 'PAYMENT', title: 'Payment Successful'),
        ),
        NotificationCategory.payment,
      );
    });

    test('maps laundry events to Laundry', () {
      expect(
        resolveNotificationCategory(
          _notification(type: 'LAUNDRY', title: 'Laundry Started'),
        ),
        NotificationCategory.laundry,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'LAUNDRY', title: 'Laundry Finished'),
        ),
        NotificationCategory.laundry,
      );
    });

    test('maps pickup and delivery events to Pengiriman', () {
      expect(
        resolveNotificationCategory(
          _notification(type: 'DELIVERY', title: 'Ready For Pickup'),
        ),
        NotificationCategory.delivery,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'DELIVERY', title: 'Delivery Started'),
        ),
        NotificationCategory.delivery,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'PICKUP', title: 'Pickup Completed'),
        ),
        NotificationCategory.delivery,
      );
    });

    test('maps dot-notation event keys from backend templates', () {
      expect(
        resolveNotificationCategory(
          _notification(type: 'order.created', title: 'Order Created'),
        ),
        NotificationCategory.order,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'payment.success', title: 'Payment'),
        ),
        NotificationCategory.payment,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'laundry.finished', title: 'Laundry'),
        ),
        NotificationCategory.laundry,
      );
      expect(
        resolveNotificationCategory(
          _notification(type: 'delivery.started', title: 'Delivery'),
        ),
        NotificationCategory.delivery,
      );
    });

    test('falls back to Sistem for unknown types', () {
      expect(
        resolveNotificationCategory(_notification(type: 'SYSTEM', title: 'Info')),
        NotificationCategory.system,
      );
    });
  });

  group('buildGroupedNotificationList', () {
    test('keeps newest notifications first within time groups', () {
      final now = DateTime.now();
      final items = [
        _notification(
          type: 'ORDER',
          title: 'Older Order',
          createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
        ),
        _notification(
          type: 'PAYMENT',
          title: 'Newer Payment',
          createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        ),
      ];

      final grouped = buildGroupedNotificationList(items);
      final entries = grouped.whereType<NotificationEntryItem>().toList();

      expect(entries.first.notification.title, 'Newer Payment');
      expect(entries.last.notification.title, 'Older Order');
    });
  });
}
