import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';

class OperationalSummary {
  const OperationalSummary({
    required this.newOrders,
    required this.inProgress,
    required this.readyForPickup,
    required this.orders,
    required this.laundry,
    required this.finance,
  });

  final int newOrders;
  final int inProgress;
  final int readyForPickup;
  final Map<String, dynamic> orders;
  final Map<String, dynamic> laundry;
  final Map<String, dynamic> finance;
}

int computeLaundryInProgress(Map<String, dynamic> laundry) {
  const stageKeys = [
    'receiving',
    'waitingWashing',
    'currentlyWashing',
    'waitingDrying',
    'currentlyDrying',
    'waitingIroning',
    'currentlyIroning',
    'qualityCheck',
  ];

  return stageKeys.fold<int>(
    0,
    (sum, key) => sum + ((laundry[key] as num?)?.toInt() ?? 0),
  );
}

final operationalSummaryProvider =
    FutureProvider<OperationalSummary>((ref) async {
  final permissions = StaffPermissions(ref.watch(sessionProvider).permissions);

  final ordersFuture = permissions.orders
      ? ref.read(orderRepositoryProvider).fetchStatistics()
      : Future<Map<String, dynamic>>.value(const {});

  final laundryFuture = permissions.ironing
      ? ref.read(laundryRepositoryProvider).fetchDashboard()
      : Future<Map<String, dynamic>>.value(const {});

  final financeFuture = permissions.finance
      ? ref.read(financeRepositoryProvider).fetchDashboard()
      : Future<Map<String, dynamic>>.value(const {});

  final results = await Future.wait([
    ordersFuture,
    laundryFuture,
    financeFuture,
  ]);

  final orders = results[0];
  final laundry = results[1];
  final finance = results[2];

  return OperationalSummary(
    newOrders: (orders['todayOrders'] as num?)?.toInt() ?? 0,
    inProgress: computeLaundryInProgress(laundry),
    readyForPickup: (laundry['readyForPickup'] as num?)?.toInt() ?? 0,
    orders: orders,
    laundry: laundry,
    finance: finance,
  );
});
