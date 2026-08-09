enum BinatuNotificationType {
  newIroningJob,
  ironingJobAccepted,
  ironingFinished,
  todaysDeadline,
  readyForCashier,
}

extension BinatuNotificationTypeX on BinatuNotificationType {
  String get title => switch (this) {
        BinatuNotificationType.newIroningJob => 'New Ironing Job',
        BinatuNotificationType.ironingJobAccepted => 'Ironing Job Accepted',
        BinatuNotificationType.ironingFinished => 'Ironing Finished',
        BinatuNotificationType.todaysDeadline => "Today's Deadline",
        BinatuNotificationType.readyForCashier => 'Ready for Cashier',
      };

  String get icon => switch (this) {
        BinatuNotificationType.newIroningJob => '🆕',
        BinatuNotificationType.ironingJobAccepted => '✅',
        BinatuNotificationType.ironingFinished => '👔',
        BinatuNotificationType.todaysDeadline => '⏰',
        BinatuNotificationType.readyForCashier => '🛎️',
      };
}

class BinatuNotification {
  const BinatuNotification({
    required this.id,
    required this.type,
    required this.orderNumber,
    required this.customerName,
    required this.createdAt,
    this.service,
    this.weightKg,
    this.assignedBinatu,
    this.message,
  });

  final String id;
  final BinatuNotificationType type;
  final String orderNumber;
  final String customerName;
  final DateTime createdAt;
  final String? service;
  final double? weightKg;
  final String? assignedBinatu;
  final String? message;
}
