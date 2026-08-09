class CustomerStatistics {
  const CustomerStatistics({
    required this.totalOrders,
    required this.lastOrder,
    required this.totalSpending,
    required this.averageOrderValue,
  });

  final int totalOrders;
  final String lastOrder;
  final int totalSpending;
  final int averageOrderValue;
}
