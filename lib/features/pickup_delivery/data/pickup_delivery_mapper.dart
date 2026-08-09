import 'package:yelo_laundry_erp/features/pickup_delivery/models/pickup_delivery_request.dart';

PickupDeliveryStatus mapPickupDeliveryStatus(
  String? status, {
  required bool isPickup,
}) {
  final normalized = status?.toUpperCase() ?? '';

  if (isPickup) {
    return switch (normalized) {
      'PICKED_UP' || 'COMPLETED' => PickupDeliveryStatus.pickupCompleted,
      _ => PickupDeliveryStatus.pickupScheduled,
    };
  }

  return switch (normalized) {
    'DELIVERED' || 'COMPLETED' => PickupDeliveryStatus.deliveryCompleted,
    _ => PickupDeliveryStatus.deliveryScheduled,
  };
}

PickupDeliveryRequest mapPickupDeliveryJob(Map<String, dynamic> json) {
  final order = json['order'] as Map<String, dynamic>? ?? {};
  final address = json['address'] as Map<String, dynamic>? ?? {};
  final jobType = (json['jobType'] as String? ?? 'PICKUP').toUpperCase();
  final isPickup = jobType == 'PICKUP';
  final scheduledAt = DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
      DateTime.now();
  final addressDetail = [
    address['addressDetail'] as String?,
    address['district'] as String?,
    address['city'] as String?,
  ].whereType<String>().where((part) => part.isNotEmpty).join(', ');

  return PickupDeliveryRequest(
    id: json['id'] as String? ?? '',
    customerName: order['customerName'] as String? ??
        address['recipientName'] as String? ??
        '',
    customerPhone: order['customerPhone'] as String? ??
        address['phone'] as String? ??
        '',
    pickupTime: _formatTime(scheduledAt),
    deliveryTime: _formatTime(scheduledAt),
    address: addressDetail.isEmpty ? '-' : addressDetail,
    notes: json['notes'] as String? ?? '',
    status: mapPickupDeliveryStatus(
      json['status'] as String?,
      isPickup: isPickup,
    ),
    scheduledDate: scheduledAt,
    mapsQuery: address['addressDetail'] as String?,
  );
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}
