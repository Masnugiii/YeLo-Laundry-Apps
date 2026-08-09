import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

enum LaundryStatus {
  menunggu,
  dicuci,
  dikeringkan,
  disetrika,
  selesai,
  readyPickup,
}

enum ServiceType {
  regular,
  express,
  premium,
}

enum PickupDeliveryType {
  antar,
  jemput,
  datangSendiri,
}

enum OrderPaymentMethod {
  cash,
  qris,
  transfer,
}

class TodayOrder {
  const TodayOrder({
    required this.queueNumber,
    required this.customerName,
    required this.weightKg,
    required this.totalPrice,
    required this.status,
    required this.serviceType,
    required this.pickupDelivery,
    required this.paymentMethod,
  });

  final String queueNumber;
  final String customerName;
  final double weightKg;
  final String totalPrice;
  final LaundryStatus status;
  final ServiceType serviceType;
  final PickupDeliveryType pickupDelivery;
  final OrderPaymentMethod paymentMethod;
}

extension LaundryStatusX on LaundryStatus {
  String get label => switch (this) {
        LaundryStatus.menunggu => 'Menunggu',
        LaundryStatus.dicuci => 'Dicuci',
        LaundryStatus.dikeringkan => 'Dikeringkan',
        LaundryStatus.disetrika => 'Disetrika',
        LaundryStatus.selesai => 'Selesai',
        LaundryStatus.readyPickup => 'Siap Diambil',
      };

  Color get badgeBackground => switch (this) {
        LaundryStatus.menunggu => AppColors.accent,
        LaundryStatus.dicuci => AppColors.primary,
        LaundryStatus.dikeringkan => AppColors.primary,
        LaundryStatus.disetrika => AppColors.primary,
        LaundryStatus.selesai => const Color(0xFF16A34A),
        LaundryStatus.readyPickup => const Color(0xFF22C55E),
      };

  Color get badgeText => switch (this) {
        LaundryStatus.menunggu => AppColors.primary,
        LaundryStatus.dicuci => AppColors.onPrimary,
        LaundryStatus.dikeringkan => AppColors.onPrimary,
        LaundryStatus.disetrika => AppColors.onPrimary,
        LaundryStatus.selesai => AppColors.onPrimary,
        LaundryStatus.readyPickup => AppColors.onPrimary,
      };
}

extension ServiceTypeX on ServiceType {
  String get label => switch (this) {
        ServiceType.regular => 'Regular',
        ServiceType.express => 'Express',
        ServiceType.premium => 'Premium',
      };

  Color get accentBarColor => switch (this) {
        ServiceType.regular => AppColors.primary,
        ServiceType.express => AppColors.accent,
        ServiceType.premium => AppColors.primary,
      };

  Color get badgeBackground => AppColors.primary;

  Color get badgeText => AppColors.onPrimary;
}

extension PickupDeliveryTypeX on PickupDeliveryType {
  String get label => switch (this) {
        PickupDeliveryType.antar => 'Antar',
        PickupDeliveryType.jemput => 'Jemput',
        PickupDeliveryType.datangSendiri => 'Datang Sendiri',
      };

  Color get badgeBackground => switch (this) {
        PickupDeliveryType.antar => const Color(0xFFE3F2FD),
        PickupDeliveryType.jemput => const Color(0xFFE8F5E9),
        PickupDeliveryType.datangSendiri => const Color(0xFFF3F4F6),
      };

  Color get badgeText => switch (this) {
        PickupDeliveryType.antar => const Color(0xFF1565C0),
        PickupDeliveryType.jemput => const Color(0xFF2E7D32),
        PickupDeliveryType.datangSendiri => const Color(0xFF9CA3AF),
      };

  Color? get badgeBorder => null;
}

extension OrderPaymentMethodX on OrderPaymentMethod {
  String get label => switch (this) {
        OrderPaymentMethod.cash => 'Cash',
        OrderPaymentMethod.qris => 'QRIS',
        OrderPaymentMethod.transfer => 'Transfer',
      };

  Color get badgeBackground => switch (this) {
        OrderPaymentMethod.cash => AppColors.accent,
        OrderPaymentMethod.qris => AppColors.accent,
        OrderPaymentMethod.transfer => AppColors.primary,
      };

  Color get badgeText => switch (this) {
        OrderPaymentMethod.cash => AppColors.primary,
        OrderPaymentMethod.qris => AppColors.primary,
        OrderPaymentMethod.transfer => AppColors.onPrimary,
      };

  Color? get badgeBorder => null;
}
