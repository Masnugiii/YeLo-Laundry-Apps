import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/widgets/notification_card.dart';

enum NotificationCategory {
  order,
  payment,
  laundry,
  delivery,
  promo,
  loyalty,
  system,
}

extension NotificationCategoryLabels on NotificationCategory {
  String get label => switch (this) {
        NotificationCategory.order => 'Pesanan',
        NotificationCategory.payment => 'Pembayaran',
        NotificationCategory.laundry => 'Laundry',
        NotificationCategory.delivery => 'Pengiriman',
        NotificationCategory.promo => 'Promo',
        NotificationCategory.loyalty => 'Loyalty / Poin',
        NotificationCategory.system => 'Sistem',
      };

  IconData get icon => switch (this) {
        NotificationCategory.order => Icons.receipt_long_outlined,
        NotificationCategory.payment => Icons.payment_outlined,
        NotificationCategory.laundry => Icons.local_laundry_service_outlined,
        NotificationCategory.delivery => Icons.local_shipping_outlined,
        NotificationCategory.promo => Icons.local_offer_outlined,
        NotificationCategory.loyalty => Icons.stars_outlined,
        NotificationCategory.system => Icons.notifications_outlined,
      };
}

NotificationCategory resolveNotificationCategory(AppNotification notification) {
  final type = notification.type.toLowerCase();
  final title = notification.title.toLowerCase();
  final message = notification.message.toLowerCase();

  if (type.contains('.')) {
    if (type.startsWith('order.')) return NotificationCategory.order;
    if (type.startsWith('payment.') || type.startsWith('refund.')) {
      return NotificationCategory.payment;
    }
    if (type.startsWith('laundry.')) return NotificationCategory.laundry;
    if (type.startsWith('pickup.') ||
        type.startsWith('delivery.') ||
        type.startsWith('driver.')) {
      return NotificationCategory.delivery;
    }
    if (type.startsWith('promotion') || type == 'promotion') {
      return NotificationCategory.promo;
    }
    if (type.startsWith('wallet.')) return NotificationCategory.loyalty;
  }

  switch (type.toUpperCase()) {
    case 'ORDER':
      return NotificationCategory.order;
    case 'PAYMENT':
    case 'FINANCE':
      return NotificationCategory.payment;
    case 'LAUNDRY':
      return NotificationCategory.laundry;
    case 'DELIVERY':
    case 'PICKUP':
      return NotificationCategory.delivery;
    case 'PROMOTION':
      return NotificationCategory.promo;
  }

  if (_containsAny(title, const ['point', 'poin', 'reward', 'loyalty', 'member'])) {
    return NotificationCategory.loyalty;
  }
  if (_containsAny(title, const ['promo', 'diskon', 'voucher'])) {
    return NotificationCategory.promo;
  }
  if (_containsAny(title, const ['laundry', 'cucian', 'setrika'])) {
    return NotificationCategory.laundry;
  }
  if (_containsAny(title, const ['pembayaran', 'payment', 'refund'])) {
    return NotificationCategory.payment;
  }
  if (_containsAny(title, const ['pesanan', 'order'])) {
    return NotificationCategory.order;
  }
  if (_containsAny(title, const ['kurir', 'pengiriman', 'pickup', 'delivery', 'antar'])) {
    return NotificationCategory.delivery;
  }
  if (_containsAny(message, const ['point', 'poin', 'wallet', 'saldo'])) {
    return NotificationCategory.loyalty;
  }

  return NotificationCategory.system;
}

bool _containsAny(String value, List<String> needles) {
  return needles.any(value.contains);
}

enum NotificationTimeGroup {
  today,
  yesterday,
  thisWeek,
  earlier,
}

extension NotificationTimeGroupLabels on NotificationTimeGroup {
  String get label => switch (this) {
        NotificationTimeGroup.today => 'HARI INI',
        NotificationTimeGroup.yesterday => 'KEMARIN',
        NotificationTimeGroup.thisWeek => 'MINGGU INI',
        NotificationTimeGroup.earlier => 'SEBELUMNYA',
      };
}

NotificationTimeGroup resolveNotificationTimeGroup(DateTime dateTime) {
  final now = DateTime.now();
  final local = dateTime.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(local.year, local.month, local.day);
  final dayDiff = today.difference(dateOnly).inDays;

  if (dayDiff == 0) return NotificationTimeGroup.today;
  if (dayDiff == 1) return NotificationTimeGroup.yesterday;
  if (dayDiff < 7) return NotificationTimeGroup.thisWeek;
  return NotificationTimeGroup.earlier;
}

sealed class NotificationListItem {}

class NotificationTimeGroupHeaderItem extends NotificationListItem {
  NotificationTimeGroupHeaderItem(this.group);

  final NotificationTimeGroup group;
}

class NotificationCategoryHeaderItem extends NotificationListItem {
  NotificationCategoryHeaderItem(this.category);

  final NotificationCategory category;
}

class NotificationEntryItem extends NotificationListItem {
  NotificationEntryItem(this.notification, this.category);

  final AppNotification notification;
  final NotificationCategory category;
}

List<NotificationListItem> buildGroupedNotificationList(
  List<AppNotification> notifications,
) {
  final sorted = [...notifications]..sort((a, b) {
      final aDate = NotificationFormat.parseDate(a.createdAt);
      final bDate = NotificationFormat.parseDate(b.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

  final items = <NotificationListItem>[];
  NotificationTimeGroup? currentTimeGroup;
  NotificationCategory? currentCategory;

  for (final notification in sorted) {
    final createdAt = NotificationFormat.parseDate(notification.createdAt);
    if (createdAt == null) continue;

    final timeGroup = resolveNotificationTimeGroup(createdAt);
    final category = resolveNotificationCategory(notification);

    if (timeGroup != currentTimeGroup) {
      currentTimeGroup = timeGroup;
      currentCategory = null;
      items.add(NotificationTimeGroupHeaderItem(timeGroup));
    }

    if (category != currentCategory) {
      currentCategory = category;
      items.add(NotificationCategoryHeaderItem(category));
    }

    items.add(NotificationEntryItem(notification, category));
  }

  return items;
}
