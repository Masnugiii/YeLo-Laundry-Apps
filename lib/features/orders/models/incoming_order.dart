import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/orders/models/order_timeline_entry.dart';

enum OrderPaymentStatus {
  belumLunas,
  lunas,
}

extension OrderPaymentStatusX on OrderPaymentStatus {
  String get label => switch (this) {
        OrderPaymentStatus.belumLunas => 'Belum Lunas',
        OrderPaymentStatus.lunas => 'Lunas',
      };
}

enum LaundryServiceType {
  regular,
  express,
  bedCover,
  ironOnly,
}

extension LaundryServiceTypeX on LaundryServiceType {
  String get label => switch (this) {
        LaundryServiceType.regular => 'Regular',
        LaundryServiceType.express => 'Express',
        LaundryServiceType.bedCover => 'Bed Cover',
        LaundryServiceType.ironOnly => 'Iron Only',
      };
}

enum FulfillmentType {
  selfPickup,
  pickup,
  delivery,
}

extension FulfillmentTypeX on FulfillmentType {
  String get label => switch (this) {
        FulfillmentType.selfPickup => 'Datang Sendiri',
        FulfillmentType.pickup => 'Pickup',
        FulfillmentType.delivery => 'Delivery',
      };
}

enum OrderWorkflowStep {
  orderReceived,
  pickup,
  washing,
  drying,
  ironing,
  qualityCheck,
  readyForPickup,
  delivery,
  completed,
}

extension OrderWorkflowStepX on OrderWorkflowStep {
  String get label => switch (this) {
        OrderWorkflowStep.orderReceived => 'Order Diterima',
        OrderWorkflowStep.pickup => 'Pickup',
        OrderWorkflowStep.washing => 'Dicuci',
        OrderWorkflowStep.drying => 'Dikeringkan',
        OrderWorkflowStep.ironing => 'Disetrika',
        OrderWorkflowStep.qualityCheck => 'Quality Check',
        OrderWorkflowStep.readyForPickup => 'Siap Diambil',
        OrderWorkflowStep.delivery => 'Delivery',
        OrderWorkflowStep.completed => 'Selesai',
      };

  static const orderedSteps = OrderWorkflowStep.values;

  String get updateStatusLabel => switch (this) {
        OrderWorkflowStep.orderReceived => 'Order Diterima',
        OrderWorkflowStep.pickup => 'Pickup',
        OrderWorkflowStep.washing => 'Sedang Dicuci',
        OrderWorkflowStep.drying => 'Sedang Dikeringkan',
        OrderWorkflowStep.ironing => 'Sedang Disetrika',
        OrderWorkflowStep.qualityCheck => 'Quality Check',
        OrderWorkflowStep.readyForPickup => 'Siap Diambil',
        OrderWorkflowStep.delivery => 'Sedang Delivery',
        OrderWorkflowStep.completed => 'Selesai',
      };
}

IncomingOrderStatus incomingOrderStatusForStep(OrderWorkflowStep step) {
  return switch (step) {
    OrderWorkflowStep.orderReceived => IncomingOrderStatus.orderBaru,
    OrderWorkflowStep.pickup => IncomingOrderStatus.sedangPickup,
    OrderWorkflowStep.washing => IncomingOrderStatus.sedangDicuci,
    OrderWorkflowStep.drying => IncomingOrderStatus.sedangDikeringkan,
    OrderWorkflowStep.ironing => IncomingOrderStatus.sedangDisetrika,
    OrderWorkflowStep.qualityCheck => IncomingOrderStatus.qualityCheck,
    OrderWorkflowStep.readyForPickup => IncomingOrderStatus.siapDiambil,
    OrderWorkflowStep.delivery => IncomingOrderStatus.sedangDelivery,
    OrderWorkflowStep.completed => IncomingOrderStatus.selesai,
  };
}

enum IncomingOrderStatus {
  orderBaru,
  sedangPickup,
  sedangDicuci,
  sedangDikeringkan,
  sedangDisetrika,
  qualityCheck,
  siapDiambil,
  sedangDelivery,
  selesai,
}

extension IncomingOrderStatusX on IncomingOrderStatus {
  String get label => switch (this) {
        IncomingOrderStatus.orderBaru => 'Order Baru',
        IncomingOrderStatus.sedangPickup => 'Sedang Pickup',
        IncomingOrderStatus.sedangDicuci => 'Sedang Dicuci',
        IncomingOrderStatus.sedangDikeringkan => 'Sedang Dikeringkan',
        IncomingOrderStatus.sedangDisetrika => 'Sedang Disetrika',
        IncomingOrderStatus.qualityCheck => 'Quality Check',
        IncomingOrderStatus.siapDiambil => 'Siap Diambil',
        IncomingOrderStatus.sedangDelivery => 'Sedang Delivery',
        IncomingOrderStatus.selesai => 'Selesai',
      };

  Color get backgroundColor => switch (this) {
        IncomingOrderStatus.orderBaru => const Color(0xFF033B8E),
        IncomingOrderStatus.sedangPickup => const Color(0xFF2563EB),
        IncomingOrderStatus.sedangDicuci => const Color(0xFF0EA5E9),
        IncomingOrderStatus.sedangDikeringkan => const Color(0xFF06B6D4),
        IncomingOrderStatus.sedangDisetrika => const Color(0xFF8B5CF6),
        IncomingOrderStatus.qualityCheck => const Color(0xFFF59E0B),
        IncomingOrderStatus.siapDiambil => const Color(0xFF16A34A),
        IncomingOrderStatus.sedangDelivery => const Color(0xFF7C3AED),
        IncomingOrderStatus.selesai => const Color(0xFF6B7280),
      };

  Color get textColor => switch (this) {
        IncomingOrderStatus.orderBaru => Colors.white,
        IncomingOrderStatus.qualityCheck => const Color(0xFF1F2937),
        _ => Colors.white,
      };
}

class ScheduleInfo {
  const ScheduleInfo({
    required this.dateTime,
    required this.pic,
  });

  final DateTime dateTime;
  final String pic;
}

class PicAssignment {
  const PicAssignment({
    required this.pickup,
    required this.washing,
    required this.ironing,
    required this.qualityCheck,
    required this.delivery,
  });

  final String pickup;
  final String washing;
  final String ironing;
  final String qualityCheck;
  final String delivery;
}

class IncomingOrder {
  const IncomingOrder({
    required this.id,
    required this.queueNumber,
    required this.customerName,
    required this.service,
    required this.orderValue,
    required this.fulfillmentType,
    required this.receivedAt,
    required this.estimatedCompletion,
    required this.currentStep,
    required this.status,
    required this.picAssignment,
    required this.weightKg,
    this.pickupInfo,
    this.deliveryInfo,
    this.isNew = false,
    this.paymentStatus = OrderPaymentStatus.belumLunas,
    this.serviceDisplayName,
    this.customerPhone = '',
    this.invoiceNumber = '',
    this.itemCount = 0,
    this.assignedEmployeeName = '-',
    this.apiPaymentMethod,
    this.isLaundryJobAccepted = false,
    this.laundryPic,
    this.laundryAcceptedAt,
    this.laundryAcceptedBy,
    this.timelineEntries = const [],
  });

  final String id;
  final String queueNumber;
  final String customerName;
  final LaundryServiceType service;
  final int orderValue;
  final FulfillmentType fulfillmentType;
  final DateTime receivedAt;
  final DateTime estimatedCompletion;
  final OrderWorkflowStep currentStep;
  final IncomingOrderStatus status;
  final PicAssignment picAssignment;
  final double weightKg;
  final ScheduleInfo? pickupInfo;
  final ScheduleInfo? deliveryInfo;
  final bool isNew;
  final OrderPaymentStatus paymentStatus;
  final String? serviceDisplayName;
  final String customerPhone;
  final String invoiceNumber;
  final int itemCount;
  final String assignedEmployeeName;
  final String? apiPaymentMethod;
  final bool isLaundryJobAccepted;
  final String? laundryPic;
  final DateTime? laundryAcceptedAt;
  final String? laundryAcceptedBy;
  final List<OrderTimelineEntry> timelineEntries;

  String get serviceLabel => serviceDisplayName ?? service.label;

  bool get canAcceptLaundryJob =>
      !isLaundryJobAccepted && status == IncomingOrderStatus.orderBaru;

  IncomingOrder copyWith({
    OrderWorkflowStep? currentStep,
    IncomingOrderStatus? status,
    OrderPaymentStatus? paymentStatus,
    String? serviceDisplayName,
    bool? isLaundryJobAccepted,
    String? laundryPic,
    DateTime? laundryAcceptedAt,
    String? laundryAcceptedBy,
    List<OrderTimelineEntry>? timelineEntries,
    PicAssignment? picAssignment,
  }) {
    return IncomingOrder(
      id: id,
      queueNumber: queueNumber,
      customerName: customerName,
      service: service,
      orderValue: orderValue,
      fulfillmentType: fulfillmentType,
      receivedAt: receivedAt,
      estimatedCompletion: estimatedCompletion,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      picAssignment: picAssignment ?? this.picAssignment,
      weightKg: weightKg,
      pickupInfo: pickupInfo,
      deliveryInfo: deliveryInfo,
      isNew: isNew,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      serviceDisplayName: serviceDisplayName ?? this.serviceDisplayName,
      customerPhone: customerPhone,
      invoiceNumber: invoiceNumber,
      itemCount: itemCount,
      assignedEmployeeName: assignedEmployeeName,
      apiPaymentMethod: apiPaymentMethod,
      isLaundryJobAccepted:
          isLaundryJobAccepted ?? this.isLaundryJobAccepted,
      laundryPic: laundryPic ?? this.laundryPic,
      laundryAcceptedAt: laundryAcceptedAt ?? this.laundryAcceptedAt,
      laundryAcceptedBy: laundryAcceptedBy ?? this.laundryAcceptedBy,
      timelineEntries: timelineEntries ?? this.timelineEntries,
    );
  }
}

String formatOrderDateTime(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = months[dateTime.month - 1];
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day $month ${dateTime.year}\n$hour:$minute WIB';
}

String formatNavOrderBadgeCount(int count) {
  if (count <= 0) return '';
  if (count > 99) return '99+';
  return '$count';
}

String formatWhatsappEstimatedCompletion(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = months[dateTime.month - 1];
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day $month ${dateTime.year}\n$hour.$minute WIB';
}

String buildWhatsappUpdateMessage(IncomingOrder order) {
  return 'Halo ${order.customerName} 👋\n\n'
      'Laundry Anda dengan nomor antrian ${order.queueNumber} saat ini sedang dalam proses:\n\n'
      '✅ ${order.currentStep.updateStatusLabel}\n\n'
      'Estimasi selesai:\n\n'
      '${formatWhatsappEstimatedCompletion(order.estimatedCompletion)}\n\n'
      'Terima kasih telah menggunakan Yelo Laundry.';
}
