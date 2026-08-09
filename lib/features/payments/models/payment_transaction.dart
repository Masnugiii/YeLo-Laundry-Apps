import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/payments/theme/payment_colors.dart';

enum PaymentMethod {
  cash,
  qris,
  transfer,
  yeloWallet,
}

enum LaundryServiceType {
  regular,
  express,
  bedCover,
  ironOnly,
}

enum PaymentPickupDelivery {
  datangSendiri,
  antar,
  jemput,
}

enum PaymentLaundryStatus {
  menunggu,
  dicuci,
  dikeringkan,
  disetrika,
  siapDiambil,
  selesai,
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.customerName,
    required this.queueNumber,
    required this.service,
    required this.weightKg,
    required this.totalPayment,
    required this.paymentMethod,
    required this.pickupDelivery,
    required this.laundryStatus,
    required this.paymentTime,
    required this.paidAt,
  });

  final String customerName;
  final String queueNumber;
  final LaundryServiceType service;
  final double weightKg;
  final String totalPayment;
  final PaymentMethod paymentMethod;
  final PaymentPickupDelivery pickupDelivery;
  final PaymentLaundryStatus laundryStatus;
  final String paymentTime;
  final DateTime paidAt;
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.qris => 'QRIS',
        PaymentMethod.transfer => 'Transfer',
        PaymentMethod.yeloWallet => 'Yelo Wallet',
      };

  Color get accentBarColor => switch (this) {
        PaymentMethod.cash => PaymentColors.primary,
        PaymentMethod.qris => PaymentColors.accent,
        PaymentMethod.transfer => PaymentColors.primary,
        PaymentMethod.yeloWallet => const Color(0xFF16A34A),
      };

  Color get badgeBackground => switch (this) {
        PaymentMethod.cash => PaymentColors.primary,
        PaymentMethod.qris => PaymentColors.accent,
        PaymentMethod.transfer => PaymentColors.primary,
        PaymentMethod.yeloWallet => const Color(0xFF16A34A),
      };

  Color get badgeText => switch (this) {
        PaymentMethod.cash => PaymentColors.onPrimary,
        PaymentMethod.qris => PaymentColors.onAccent,
        PaymentMethod.transfer => PaymentColors.onPrimary,
        PaymentMethod.yeloWallet => PaymentColors.onPrimary,
      };
}

extension LaundryServiceTypeX on LaundryServiceType {
  String get label => switch (this) {
        LaundryServiceType.regular => 'Regular',
        LaundryServiceType.express => 'Express',
        LaundryServiceType.bedCover => 'Bed Cover',
        LaundryServiceType.ironOnly => 'Iron Only',
      };
}

extension PaymentPickupDeliveryX on PaymentPickupDelivery {
  String get label => switch (this) {
        PaymentPickupDelivery.datangSendiri => 'Datang Sendiri',
        PaymentPickupDelivery.antar => 'Antar',
        PaymentPickupDelivery.jemput => 'Jemput',
      };

  Color get badgeBackground => switch (this) {
        PaymentPickupDelivery.jemput => PaymentColors.primary,
        PaymentPickupDelivery.antar => PaymentColors.accent,
        PaymentPickupDelivery.datangSendiri => PaymentColors.walkInBackground,
      };

  Color get badgeText => switch (this) {
        PaymentPickupDelivery.jemput => PaymentColors.onPrimary,
        PaymentPickupDelivery.antar => PaymentColors.onAccent,
        PaymentPickupDelivery.datangSendiri => PaymentColors.walkIn,
      };
}

extension PaymentLaundryStatusX on PaymentLaundryStatus {
  String get label => switch (this) {
        PaymentLaundryStatus.menunggu => 'Menunggu',
        PaymentLaundryStatus.dicuci => 'Dicuci',
        PaymentLaundryStatus.dikeringkan => 'Dikeringkan',
        PaymentLaundryStatus.disetrika => 'Disetrika',
        PaymentLaundryStatus.siapDiambil => 'Siap Diambil',
        PaymentLaundryStatus.selesai => 'Selesai',
      };

  Color get color => switch (this) {
        PaymentLaundryStatus.menunggu => AppColors.warning,
        PaymentLaundryStatus.dicuci => AppColors.primary,
        PaymentLaundryStatus.dikeringkan => const Color(0xFF2563EB),
        PaymentLaundryStatus.disetrika => const Color(0xFF7C3AED),
        PaymentLaundryStatus.siapDiambil => const Color(0xFF059669),
        PaymentLaundryStatus.selesai => AppColors.success,
      };
}
