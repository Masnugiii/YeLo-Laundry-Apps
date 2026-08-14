import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/cashier_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/manager_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operator_dashboard_badge_provider.dart';

void markPickupDeliveryBadgeRead(WidgetRef ref, UserRole role) {
  switch (role) {
    case UserRole.cashier:
      ref.read(cashierDashboardBadgeProvider.notifier).markPickupDeliveryRead();
    case UserRole.cashierLaundry:
      ref.read(operatorDashboardBadgeProvider.notifier).markPickupDeliveryRead();
    case UserRole.cashierLaundryDriver:
      ref.read(managerDashboardBadgeProvider.notifier).markPickupDeliveryRead();
    case UserRole.owner:
    case UserRole.laundry:
    case UserRole.driver:
      break;
  }
}

void markNotificationCenterBadgeRead(WidgetRef ref, UserRole role) {
  switch (role) {
    case UserRole.cashier:
      ref
          .read(cashierDashboardBadgeProvider.notifier)
          .markNotificationCenterRead();
    case UserRole.cashierLaundry:
      ref
          .read(operatorDashboardBadgeProvider.notifier)
          .markNotificationCenterRead();
    case UserRole.cashierLaundryDriver:
      ref
          .read(managerDashboardBadgeProvider.notifier)
          .markNotificationCenterRead();
    case UserRole.owner:
    case UserRole.laundry:
    case UserRole.driver:
      break;
  }
}

void markCustomerServiceBadgeRead(WidgetRef ref, UserRole role) {
  switch (role) {
    case UserRole.cashier:
      ref.read(cashierDashboardBadgeProvider.notifier).markCustomerServiceRead();
    case UserRole.cashierLaundry:
      ref.read(operatorDashboardBadgeProvider.notifier).markCustomerServiceRead();
    case UserRole.cashierLaundryDriver:
      ref.read(managerDashboardBadgeProvider.notifier).markCustomerServiceRead();
    case UserRole.owner:
    case UserRole.laundry:
    case UserRole.driver:
      break;
  }
}
