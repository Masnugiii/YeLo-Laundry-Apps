import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

String _todayDateParam() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

class UnpaidOrdersNotifier extends AsyncNotifier<List<IncomingOrder>> {
  @override
  Future<List<IncomingOrder>> build() async {
    final response = await ref.read(orderRepositoryProvider).fetchOrders(
          paymentStatus: 'UNPAID',
          limit: 100,
        );
    return response.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

final unpaidOrdersProvider =
    AsyncNotifierProvider<UnpaidOrdersNotifier, List<IncomingOrder>>(
  UnpaidOrdersNotifier.new,
);

class TodayOrdersNotifier extends AsyncNotifier<List<IncomingOrder>> {
  @override
  Future<List<IncomingOrder>> build() async {
    final today = _todayDateParam();
    final response = await ref.read(orderRepositoryProvider).fetchOrders(
          dateFrom: today,
          dateTo: today,
          limit: 100,
        );
    return response.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

final todayOrdersProvider =
    AsyncNotifierProvider<TodayOrdersNotifier, List<IncomingOrder>>(
  TodayOrdersNotifier.new,
);
