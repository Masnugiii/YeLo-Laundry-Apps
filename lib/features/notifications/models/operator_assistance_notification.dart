class OperatorAssistanceNotification {
  const OperatorAssistanceNotification({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.weightKg,
    required this.waitingStartedAt,
    required this.createdAt,
    this.isResolved = false,
    this.acceptedBy,
    this.resolvedAt,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final double weightKg;
  final DateTime waitingStartedAt;
  final DateTime createdAt;
  final bool isResolved;
  final String? acceptedBy;
  final DateTime? resolvedAt;

  Duration get waitingTime => createdAt.difference(waitingStartedAt);

  String get waitingTimeLabel {
    final totalMinutes = waitingTime.inMinutes;
    if (totalMinutes < 60) {
      return '$totalMinutes Menit';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours Jam ${minutes.toString().padLeft(2, '0')} Menit';
  }

  OperatorAssistanceNotification copyWith({
    bool? isResolved,
    String? acceptedBy,
    DateTime? resolvedAt,
  }) {
    return OperatorAssistanceNotification(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      customerName: customerName,
      weightKg: weightKg,
      waitingStartedAt: waitingStartedAt,
      createdAt: createdAt,
      isResolved: isResolved ?? this.isResolved,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
