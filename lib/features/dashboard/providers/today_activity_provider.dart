import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/config/app_config.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/dashboard_activity_item.dart';
import 'package:yelo_laundry_erp/features/dashboard/utils/dashboard_activity_mapper.dart';

class TodayActivityState {
  const TodayActivityState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.activityDate,
  });

  final List<DashboardActivityItem> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final DateTime activityDate;

  TodayActivityState copyWith({
    List<DashboardActivityItem>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    DateTime? activityDate,
  }) {
    return TodayActivityState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activityDate: activityDate ?? this.activityDate,
    );
  }
}

class TodayActivityNotifier extends AsyncNotifier<TodayActivityState> {
  @override
  Future<TodayActivityState> build() async {
    return _load(page: 1);
  }

  Future<TodayActivityState> _load({required int page}) async {
    final activityDate = DateTime.now();
    final today = DateDisplayHelper.todayApiDateParam(activityDate);
    final response = await ref.read(orderRepositoryProvider).fetchOrders(
          page: page,
          limit: AppConfig.defaultPageSize,
          dateFrom: today,
          dateTo: today,
        );

    return TodayActivityState(
      items: response.items.map(mapOrderToDashboardActivity).toList(),
      page: page,
      hasMore: page < response.meta.totalPages,
      isLoadingMore: false,
      activityDate: activityDate,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final today = DateDisplayHelper.todayApiDateParam(current.activityDate);
    final response = await ref.read(orderRepositoryProvider).fetchOrders(
          page: current.page + 1,
          limit: AppConfig.defaultPageSize,
          dateFrom: today,
          dateTo: today,
        );

    state = AsyncData(
      current.copyWith(
        items: [
          ...current.items,
          ...response.items.map(mapOrderToDashboardActivity),
        ],
        page: current.page + 1,
        hasMore: current.page + 1 < response.meta.totalPages,
        isLoadingMore: false,
      ),
    );
  }
}

final todayActivityProvider =
    AsyncNotifierProvider<TodayActivityNotifier, TodayActivityState>(
  TodayActivityNotifier.new,
);
