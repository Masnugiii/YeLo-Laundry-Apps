import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/dashboard/data/dummy_dashboard_menu_badges.dart';

class CashierDashboardBadgeState {
  const CashierDashboardBadgeState({
    required this.pickupDeliveryUnreadCount,
    required this.notificationCenterUnreadCount,
    required this.customerServiceUnreadCount,
  });

  final int pickupDeliveryUnreadCount;
  final int notificationCenterUnreadCount;
  final int customerServiceUnreadCount;

  CashierDashboardBadgeState copyWith({
    int? pickupDeliveryUnreadCount,
    int? notificationCenterUnreadCount,
    int? customerServiceUnreadCount,
  }) {
    return CashierDashboardBadgeState(
      pickupDeliveryUnreadCount:
          pickupDeliveryUnreadCount ?? this.pickupDeliveryUnreadCount,
      notificationCenterUnreadCount:
          notificationCenterUnreadCount ?? this.notificationCenterUnreadCount,
      customerServiceUnreadCount:
          customerServiceUnreadCount ?? this.customerServiceUnreadCount,
    );
  }
}

class CashierDashboardBadgeNotifier extends Notifier<CashierDashboardBadgeState> {
  @override
  CashierDashboardBadgeState build() {
    return CashierDashboardBadgeState(
      pickupDeliveryUnreadCount: dummyCashierPickupDeliveryUnreadCount(),
      notificationCenterUnreadCount: dummyCashierNotificationCenterUnreadCount(),
      customerServiceUnreadCount: dummyCashierCustomerServiceUnreadCount(),
    );
  }

  void markPickupDeliveryRead() {
    if (state.pickupDeliveryUnreadCount == 0) return;
    state = state.copyWith(pickupDeliveryUnreadCount: 0);
  }

  void markNotificationCenterRead() {
    if (state.notificationCenterUnreadCount == 0) return;
    state = state.copyWith(notificationCenterUnreadCount: 0);
  }

  void markCustomerServiceRead() {
    if (state.customerServiceUnreadCount == 0) return;
    state = state.copyWith(customerServiceUnreadCount: 0);
  }
}

final cashierDashboardBadgeProvider =
    NotifierProvider<CashierDashboardBadgeNotifier, CashierDashboardBadgeState>(
  CashierDashboardBadgeNotifier.new,
);
