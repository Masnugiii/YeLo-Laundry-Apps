import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/config/app_config.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

class OrderListState {
  const OrderListState({
    required this.orders,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    this.search,
  });

  final List<IncomingOrder> orders;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? search;

  OrderListState copyWith({
    List<IncomingOrder>? orders,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class OrderListNotifier extends AsyncNotifier<OrderListState> {
  @override
  Future<OrderListState> build() async {
    return _load(page: 1);
  }

  Future<OrderListState> _load({
    required int page,
    String? search,
  }) async {
    final repository = ref.read(orderRepositoryProvider);
    final response = await repository.fetchOrders(
      page: page,
      limit: AppConfig.defaultPageSize,
      search: search,
    );

    return OrderListState(
      orders: response.items,
      page: page,
      hasMore: page < response.meta.totalPages,
      isLoadingMore: false,
      search: search,
    );
  }

  Future<void> refresh({String? search}) async {
    state = const AsyncLoading();
    state = AsyncData(await _load(page: 1, search: search));
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = AsyncData(
      await _load(
        page: 1,
        search: query.trim().isEmpty ? null : query.trim(),
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final repository = ref.read(orderRepositoryProvider);
    final response = await repository.fetchOrders(
      page: current.page + 1,
      limit: AppConfig.defaultPageSize,
      search: current.search,
    );

    state = AsyncData(
      current.copyWith(
        orders: [...current.orders, ...response.items],
        page: current.page + 1,
        hasMore: current.page + 1 < response.meta.totalPages,
        isLoadingMore: false,
      ),
    );
  }
}

final orderListProvider =
    AsyncNotifierProvider<OrderListNotifier, OrderListState>(
  OrderListNotifier.new,
);
