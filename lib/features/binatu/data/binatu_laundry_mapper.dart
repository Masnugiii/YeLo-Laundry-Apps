import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_order.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';

BinatuIroningStatus mapProductionStatus({
  required String productionStatus,
  String? orderStatus,
}) {
  switch (productionStatus) {
    case 'WAITING_IRON':
      if (orderStatus == 'WAITING_BINATU') {
        return BinatuIroningStatus.waitingForBinatu;
      }
      return BinatuIroningStatus.waitingForOperatorAssistance;
    case 'IRONING':
      if (orderStatus == 'CURRENTLY_IRONING') {
        return BinatuIroningStatus.currentlyIroning;
      }
      return BinatuIroningStatus.acceptedByBinatu;
    case 'QUALITY_CHECK':
      return BinatuIroningStatus.finishedIroning;
    case 'READY':
      return BinatuIroningStatus.readyForPickup;
    default:
      return BinatuIroningStatus.waitingForBinatu;
  }
}

BinatuIroningOrder mapBinatuIroningOrder(Map<String, dynamic> json) {
  final assigned = json['assignedEmployee'] as Map<String, dynamic>?;
  final productionStatus = json['productionStatus'] as String? ?? 'WAITING_IRON';
  final orderStatus = json['orderStatus'] as String?;
  final waitingStartedAt = DateTime.tryParse(
        json['stageStartedAt'] as String? ?? '',
      ) ??
      DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
      DateTime.now();
  final deadline = DateTime.tryParse(
        json['estimatedFinishDate']?.toString() ?? '',
      ) ??
      DateTime.now().add(const Duration(hours: 4));

  return BinatuIroningOrder(
    id: json['orderId'] as String? ?? json['id'] as String? ?? '',
    orderNumber: json['orderNumber'] as String? ??
        json['queueNumber'] as String? ??
        '',
    customerName: json['customerName'] as String? ?? '',
    service: json['serviceSummary'] as String? ?? '-',
    weightKg: (json['totalWeight'] as num?)?.toDouble() ?? 0,
    quantityPcs: (json['totalPieces'] as num?)?.toInt() ?? 0,
    customerNotes: '-',
    deadline: deadline,
    ironingStatus: mapProductionStatus(
      productionStatus: productionStatus,
      orderStatus: orderStatus,
    ),
    waitingStartedAt: waitingStartedAt,
    assignedBinatu: assigned?['fullName'] as String?,
    acceptedAt: assigned != null ? waitingStartedAt : null,
  );
}
