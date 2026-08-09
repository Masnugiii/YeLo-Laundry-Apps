class LaundryJobAcceptedNotification {
  const LaundryJobAcceptedNotification({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.serviceName,
    required this.weightKg,
    required this.acceptedBy,
    required this.acceptedAt,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String serviceName;
  final double weightKg;
  final String acceptedBy;
  final DateTime acceptedAt;

  String get title => '🧺 Pekerjaan Diambil';

  String get weightLabel => '${weightKg.toStringAsFixed(1)} Kg';

  String get acceptedTimeLabel {
    final hour = acceptedAt.hour.toString().padLeft(2, '0');
    final minute = acceptedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
