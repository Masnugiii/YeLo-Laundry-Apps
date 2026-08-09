import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_order_history.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_statistics.dart';

class CustomerProfile {
  const CustomerProfile({
    required this.customer,
    required this.statistics,
    required this.recentOrders,
  });

  final Customer customer;
  final CustomerStatistics statistics;
  final List<CustomerOrderHistoryItem> recentOrders;
}
