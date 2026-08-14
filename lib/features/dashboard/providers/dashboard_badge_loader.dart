import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';

int pickupDeliveryUnreadCountFromDashboard(Map<String, dynamic> dashboard) {
  const keys = [
    'pickupRequested',
    'driverAssigned',
    'onTheWay',
    'readyForDelivery',
  ];

  return keys.fold<int>(
    0,
    (sum, key) => sum + ((dashboard[key] as num?)?.toInt() ?? 0),
  );
}

Future<void> loadDashboardBadgeCounts({
  required Ref ref,
  required void Function({
    int? pickupDeliveryUnreadCount,
    int? notificationCenterUnreadCount,
    int? customerServiceUnreadCount,
  }) apply,
}) async {
  try {
    final results = await Future.wait([
      ref.read(pickupDeliveryRepositoryProvider).fetchDashboard(),
      ref.read(notificationRepositoryProvider).fetchUnreadCount(),
      ref.read(customerServiceRepositoryProvider).fetchSummary(),
    ]);

    final pickupDashboard = results[0] as Map<String, dynamic>;
    final notificationCount = results[1] as int;
    final csSummary = results[2] as CustomerServiceSummary;

    apply(
      pickupDeliveryUnreadCount:
          pickupDeliveryUnreadCountFromDashboard(pickupDashboard),
      notificationCenterUnreadCount: notificationCount,
      customerServiceUnreadCount: csSummary.unreadMessages,
    );
  } catch (_) {}
}
