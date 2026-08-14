import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/points/models/point_transaction.dart';

final pointHistoryCustomerProvider =
    FutureProvider.autoDispose.family<Customer, String>((ref, customerId) {
  return ref.read(customerRepositoryProvider).fetchCustomer(customerId);
});

final pointHistoryTransactionsProvider = FutureProvider.autoDispose
    .family<List<PointTransaction>, String>((ref, customerId) {
  return ref
      .read(loyaltyRepositoryProvider)
      .fetchPointHistory(customerId: customerId);
});
