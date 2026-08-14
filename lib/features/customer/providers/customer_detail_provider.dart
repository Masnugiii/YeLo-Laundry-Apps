import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_order_history.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_statistics.dart';

class CustomerDetailData {
  const CustomerDetailData({
    required this.customer,
    required this.walletBalance,
    required this.statistics,
    required this.recentOrders,
  });

  final Customer customer;
  final int walletBalance;
  final CustomerStatistics statistics;
  final List<CustomerOrderHistoryItem> recentOrders;
}

final customerDetailProvider =
    FutureProvider.family<CustomerDetailData, String>((ref, customerId) async {
  final permissions = ref.watch(staffPermissionsProvider);
  final customerRepository = ref.read(customerRepositoryProvider);
  final customer = await customerRepository.fetchCustomer(customerId);
  final walletBalance = permissions.wallet
      ? (await ref
              .read(walletRepositoryProvider)
              .fetchCustomerWallet(customerId))
          .balance
          .round()
      : customer.walletBalance;
  final summary = await customerRepository.fetchCustomerSummary(customerId);

  return CustomerDetailData(
    customer: customer,
    walletBalance: walletBalance,
    statistics: customerRepository.mapSummaryToStatistics(summary),
    recentOrders: const [],
  );
});
