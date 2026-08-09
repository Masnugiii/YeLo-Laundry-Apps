import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';

class BinatuIroningOrder {
  const BinatuIroningOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.service,
    required this.weightKg,
    required this.quantityPcs,
    required this.customerNotes,
    required this.deadline,
    required this.ironingStatus,
    required this.waitingStartedAt,
    this.assignedBinatu,
    this.acceptedAt,
    this.finishedAt,
    this.isOperatorAssistance = false,
    this.operatorAssistanceAvailableAt,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String service;
  final double weightKg;
  final int quantityPcs;
  final String customerNotes;
  final DateTime deadline;
  final BinatuIroningStatus ironingStatus;
  final DateTime waitingStartedAt;
  final String? assignedBinatu;
  final DateTime? acceptedAt;
  final DateTime? finishedAt;
  final bool isOperatorAssistance;
  final DateTime? operatorAssistanceAvailableAt;

  String get weightLabel => '${weightKg.toStringAsFixed(1)} Kg';

  String get quantityLabel => '$quantityPcs pcs';

  String get deadlineLabel => _formatTime(deadline);

  bool get canBinatuAccept =>
      ironingStatus == BinatuIroningStatus.waitingForBinatu;

  bool canOperatorAccept(bool allowOperatorAssistance) =>
      allowOperatorAssistance &&
      ironingStatus == BinatuIroningStatus.waitingForOperatorAssistance;

  bool get canAccept => canBinatuAccept;

  bool get canStartIroning =>
      ironingStatus == BinatuIroningStatus.acceptedByBinatu;

  bool get canFinishIroning =>
      ironingStatus == BinatuIroningStatus.currentlyIroning;

  bool get canMarkReadyForPickup =>
      ironingStatus == BinatuIroningStatus.finishedIroning;

  bool get isWaitingForBinatu =>
      ironingStatus == BinatuIroningStatus.waitingForBinatu;

  bool get isWaitingForOperatorAssistance =>
      ironingStatus == BinatuIroningStatus.waitingForOperatorAssistance;

  Duration remainingBinatuPriority(Duration waitingDuration) {
    final elapsed = DateTime.now().difference(waitingStartedAt);
    final remaining = waitingDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  BinatuIroningOrder copyWith({
    BinatuIroningStatus? ironingStatus,
    String? assignedBinatu,
    DateTime? acceptedAt,
    DateTime? finishedAt,
    bool? isOperatorAssistance,
    DateTime? operatorAssistanceAvailableAt,
    DateTime? waitingStartedAt,
  }) {
    return BinatuIroningOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      service: service,
      weightKg: weightKg,
      quantityPcs: quantityPcs,
      customerNotes: customerNotes,
      deadline: deadline,
      ironingStatus: ironingStatus ?? this.ironingStatus,
      waitingStartedAt: waitingStartedAt ?? this.waitingStartedAt,
      assignedBinatu: assignedBinatu ?? this.assignedBinatu,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      isOperatorAssistance: isOperatorAssistance ?? this.isOperatorAssistance,
      operatorAssistanceAvailableAt:
          operatorAssistanceAvailableAt ?? this.operatorAssistanceAvailableAt,
    );
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}

class BinatuDashboardSummary {
  const BinatuDashboardSummary({
    required this.waitingToBeAssigned,
    required this.currentlyIroning,
    required this.ironingCompleted,
    required this.operatorAssistanceCompleted,
    required this.todaysTargetKg,
    required this.todaysCompletedKg,
  });

  final int waitingToBeAssigned;
  final int currentlyIroning;
  final int ironingCompleted;
  final int operatorAssistanceCompleted;
  final double todaysTargetKg;
  final double todaysCompletedKg;
}
