import 'package:flutter/material.dart';

enum PickupDeliveryStatus {
  pickupScheduled,
  pickupCompleted,
  deliveryScheduled,
  deliveryCompleted,
}

extension PickupDeliveryStatusX on PickupDeliveryStatus {
  String get label => switch (this) {
        PickupDeliveryStatus.pickupScheduled => 'Pickup Dijadwalkan',
        PickupDeliveryStatus.pickupCompleted => 'Pickup Selesai',
        PickupDeliveryStatus.deliveryScheduled => 'Delivery Dijadwalkan',
        PickupDeliveryStatus.deliveryCompleted => 'Delivery Selesai',
      };

  Color get badgeBackground => switch (this) {
        PickupDeliveryStatus.pickupScheduled => const Color(0xFF033B8E),
        PickupDeliveryStatus.pickupCompleted => const Color(0xFF16A34A),
        PickupDeliveryStatus.deliveryScheduled => const Color(0xFFF8D613),
        PickupDeliveryStatus.deliveryCompleted => const Color(0xFF22C55E),
      };

  Color get badgeText => switch (this) {
        PickupDeliveryStatus.pickupScheduled => const Color(0xFFFFFFFF),
        PickupDeliveryStatus.pickupCompleted => const Color(0xFFFFFFFF),
        PickupDeliveryStatus.deliveryScheduled => const Color(0xFF033B8E),
        PickupDeliveryStatus.deliveryCompleted => const Color(0xFFFFFFFF),
      };

  bool get isPickupRelated => switch (this) {
        PickupDeliveryStatus.pickupScheduled => true,
        PickupDeliveryStatus.pickupCompleted => true,
        PickupDeliveryStatus.deliveryScheduled => false,
        PickupDeliveryStatus.deliveryCompleted => false,
      };

  bool get isDeliveryRelated => switch (this) {
        PickupDeliveryStatus.pickupScheduled => false,
        PickupDeliveryStatus.pickupCompleted => false,
        PickupDeliveryStatus.deliveryScheduled => true,
        PickupDeliveryStatus.deliveryCompleted => true,
      };

  bool get isCompleted => this == PickupDeliveryStatus.deliveryCompleted;

  bool get requiresManagerAction => switch (this) {
        PickupDeliveryStatus.pickupScheduled => true,
        PickupDeliveryStatus.deliveryScheduled => true,
        PickupDeliveryStatus.pickupCompleted => true,
        PickupDeliveryStatus.deliveryCompleted => false,
      };
}

enum PickupDeliveryFilter {
  all,
  pickup,
  delivery,
  today,
  completed,
}

extension PickupDeliveryFilterX on PickupDeliveryFilter {
  String get label => switch (this) {
        PickupDeliveryFilter.all => 'Semua',
        PickupDeliveryFilter.pickup => 'Pickup',
        PickupDeliveryFilter.delivery => 'Delivery',
        PickupDeliveryFilter.today => 'Hari Ini',
        PickupDeliveryFilter.completed => 'Selesai',
      };
}

class PickupDeliveryRequest {
  const PickupDeliveryRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupTime,
    required this.deliveryTime,
    required this.address,
    required this.notes,
    required this.status,
    required this.scheduledDate,
    this.mapsQuery,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String pickupTime;
  final String deliveryTime;
  final String address;
  final String notes;
  final PickupDeliveryStatus status;
  final DateTime scheduledDate;
  final String? mapsQuery;

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }
}
