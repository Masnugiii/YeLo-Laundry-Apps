import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';

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
  final results = await Future.wait([
    ref.read(orderRepositoryProvider).fetchStatistics(),
    ref.read(laundryRepositoryProvider).fetchDashboard(),
    ref.read(financeRepositoryProvider).fetchDashboard(),
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
