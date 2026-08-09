import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer/data/dummy_customers.dart';
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
  final customer =
      await ref.read(customerRepositoryProvider).fetchCustomer(customerId);
  final wallet =
      await ref.read(walletRepositoryProvider).fetchCustomerWallet(customerId);
  final dummyProfile = findCustomerProfile(customerId);

  return CustomerDetailData(
    customer: customer,
    walletBalance: wallet.balance.round(),
    statistics: dummyProfile?.statistics ??
        const CustomerStatistics(
          totalOrders: 0,
          lastOrder: '-',
          totalSpending: 0,
          averageOrderValue: 0,
        ),
    recentOrders: dummyProfile?.recentOrders ?? const [],
  );
});
