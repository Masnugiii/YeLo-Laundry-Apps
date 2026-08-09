enum BinatuMonitoringDateFilter {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  custom,
}

extension BinatuMonitoringDateFilterX on BinatuMonitoringDateFilter {
  String get label => switch (this) {
        BinatuMonitoringDateFilter.today => 'Today',
        BinatuMonitoringDateFilter.yesterday => 'Yesterday',
        BinatuMonitoringDateFilter.thisWeek => 'This Week',
        BinatuMonitoringDateFilter.thisMonth => 'This Month',
        BinatuMonitoringDateFilter.custom => 'Custom Date',
      };

  static BinatuMonitoringDateFilter fromQuery(String? value) {
    return BinatuMonitoringDateFilter.values.firstWhere(
      (filter) => filter.name == value,
      orElse: () => BinatuMonitoringDateFilter.today,
    );
  }
}

class BinatuMonitoringSummary {
  const BinatuMonitoringSummary({
    required this.activeBinatu,
    required this.totalIroningOrders,
    required this.totalKgIroned,
    required this.ordersStillInProgress,
  });

  final int activeBinatu;
  final int totalIroningOrders;
  final double totalKgIroned;
  final int ordersStillInProgress;
}

class BinatuEmployeeMonitoring {
  const BinatuEmployeeMonitoring({
    required this.id,
    required this.name,
    required this.isActive,
    required this.totalIroningOrders,
    required this.totalKgIroned,
  });

  final String id;
  final String name;
  final bool isActive;
  final int totalIroningOrders;
  final double totalKgIroned;
}

class BinatuMonitoringOrder {
  const BinatuMonitoringOrder({
    required this.id,
    required this.employeeId,
    required this.orderNumber,
    required this.customerName,
    required this.laundryService,
    required this.weightKg,
    required this.status,
    required this.workDate,
    required this.acceptedAt,
    this.finishedAt,
  });

  final String id;
  final String employeeId;
  final String orderNumber;
  final String customerName;
  final String laundryService;
  final double weightKg;
  final String status;
  final DateTime workDate;
  final DateTime acceptedAt;
  final DateTime? finishedAt;

  String get weightLabel => '${weightKg.toStringAsFixed(1)} Kg';

  String get acceptedTimeLabel => _formatTime(acceptedAt);

  String? get finishedTimeLabel =>
      finishedAt == null ? null : _formatTime(finishedAt!);

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
