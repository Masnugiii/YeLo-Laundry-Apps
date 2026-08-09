import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/config/app_config.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/dashboard_employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';

class CustomerListState {
  const CustomerListState({
    required this.customers,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    this.search,
  });

  final List<Customer> customers;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? search;

  CustomerListState copyWith({
    List<Customer>? customers,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
    );
  }
}

class CustomerListNotifier extends AsyncNotifier<CustomerListState> {
  @override
  Future<CustomerListState> build() async {
    return _load(page: 1);
  }

  Future<CustomerListState> _load({
    required int page,
    String? search,
  }) async {
    final repository = ref.read(customerRepositoryProvider);
    final response = await repository.fetchCustomers(
      page: page,
      limit: AppConfig.defaultPageSize,
      search: search,
    );

    return CustomerListState(
      customers: response.items,
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

    final repository = ref.read(customerRepositoryProvider);
    final response = await repository.fetchCustomers(
      page: current.page + 1,
      limit: AppConfig.defaultPageSize,
      search: current.search,
    );

    state = AsyncData(
      current.copyWith(
        customers: [...current.customers, ...response.items],
        page: current.page + 1,
        hasMore: current.page + 1 < response.meta.totalPages,
        isLoadingMore: false,
      ),
    );
  }
}

final customerListProvider =
    AsyncNotifierProvider<CustomerListNotifier, CustomerListState>(
  CustomerListNotifier.new,
);

final dashboardEmployeeProvider = Provider<DashboardEmployee>((ref) {
  final session = ref.watch(sessionProvider);
  return DashboardEmployee(
    name: session.name.isEmpty ? 'Employee' : session.name,
    gender: EmployeeGender.male,
    role: EmployeeRole.owner,
    positionLabel: session.role.label,
  );
});
