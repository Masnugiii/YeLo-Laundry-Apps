class CustomerOrderHistoryItem {
  const CustomerOrderHistoryItem({
    required this.queueNumber,
    required this.laundryService,
    required this.orderValue,
    required this.status,
    required this.date,
  });

  final String queueNumber;
  final String laundryService;
  final int orderValue;
  final String status;
  final String date;
}
