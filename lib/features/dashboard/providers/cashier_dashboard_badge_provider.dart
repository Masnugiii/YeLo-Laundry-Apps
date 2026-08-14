import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_badge_loader.dart';

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
    Future.microtask(_loadApiCounts);
    return const CashierDashboardBadgeState(
      pickupDeliveryUnreadCount: 0,
      notificationCenterUnreadCount: 0,
      customerServiceUnreadCount: 0,
    );
  }

  Future<void> _loadApiCounts() async {
    await loadDashboardBadgeCounts(
      ref: ref,
      apply: ({
        pickupDeliveryUnreadCount,
        notificationCenterUnreadCount,
        customerServiceUnreadCount,
      }) {
        state = state.copyWith(
          pickupDeliveryUnreadCount: pickupDeliveryUnreadCount,
          notificationCenterUnreadCount: notificationCenterUnreadCount,
          customerServiceUnreadCount: customerServiceUnreadCount,
        );
      },
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
