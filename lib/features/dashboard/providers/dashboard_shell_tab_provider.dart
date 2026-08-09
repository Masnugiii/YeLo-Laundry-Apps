import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardShellTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

/// Shared bottom-navigation index for role dashboards (non-laundry roles).
final dashboardShellTabProvider =
    NotifierProvider<DashboardShellTabNotifier, int>(
  DashboardShellTabNotifier.new,
);

/// Incoming orders tab index for owner/cashier dashboards.
const incomingOrdersDashboardTabIndex = 2;
