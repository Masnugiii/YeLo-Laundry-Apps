import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

enum UnpaidPaymentStatus {
  belumDibayar,
  sudahDibayar,
}

extension UnpaidPaymentStatusX on UnpaidPaymentStatus {
  String get label => switch (this) {
        UnpaidPaymentStatus.belumDibayar => 'Belum Dibayar',
        UnpaidPaymentStatus.sudahDibayar => 'Sudah Dibayar',
      };

  Color get backgroundColor => switch (this) {
        UnpaidPaymentStatus.belumDibayar => const Color(0xFFFFEBEE),
        UnpaidPaymentStatus.sudahDibayar => const Color(0xFFE8F5E9),
      };

  Color get textColor => switch (this) {
        UnpaidPaymentStatus.belumDibayar => const Color(0xFFC62828),
        UnpaidPaymentStatus.sudahDibayar => const Color(0xFF2E7D32),
      };
}

enum UnpaidServiceType {
  regular,
  express,
  bedCover,
  ironOnly,
}

extension UnpaidServiceTypeX on UnpaidServiceType {
  String get label => switch (this) {
        UnpaidServiceType.regular => 'Regular',
        UnpaidServiceType.express => 'Express',
        UnpaidServiceType.bedCover => 'Bed Cover',
        UnpaidServiceType.ironOnly => 'Iron Only',
      };
}

enum UnpaidFulfillmentType {
  selfPickup,
  pickup,
  delivery,
}

extension UnpaidFulfillmentTypeX on UnpaidFulfillmentType {
  String get label => switch (this) {
        UnpaidFulfillmentType.selfPickup => 'Datang Sendiri',
        UnpaidFulfillmentType.pickup => 'Pickup',
        UnpaidFulfillmentType.delivery => 'Delivery',
      };
}

enum UnpaidOrderFilter {
  semua,
  belumDibayar,
  terlambatDiambil,
  pickup,
  delivery,
}

extension UnpaidOrderFilterX on UnpaidOrderFilter {
  String get label => switch (this) {
        UnpaidOrderFilter.semua => 'Semua',
        UnpaidOrderFilter.belumDibayar => 'Belum Dibayar',
        UnpaidOrderFilter.terlambatDiambil => 'Terlambat Diambil',
        UnpaidOrderFilter.pickup => 'Pickup',
        UnpaidOrderFilter.delivery => 'Delivery',
      };
}

enum UnpaidOrderSort {
  tanggalMasuk,
  nomorAntrian,
  namaCustomer,
  nilaiTagihan,
  jumlahDenda,
}

extension UnpaidOrderSortX on UnpaidOrderSort {
  String get label => switch (this) {
        UnpaidOrderSort.tanggalMasuk => 'Tanggal Masuk',
        UnpaidOrderSort.nomorAntrian => 'Nomor Antrian',
        UnpaidOrderSort.namaCustomer => 'Nama Customer',
        UnpaidOrderSort.nilaiTagihan => 'Nilai Tagihan',
        UnpaidOrderSort.jumlahDenda => 'Jumlah Denda',
      };
}

class UnpaidOrdersSummary {
  const UnpaidOrdersSummary({
    required this.totalOrders,
    required this.totalReceivable,
    required this.dueTodayCount,
    required this.latePickupCount,
  });

  final int totalOrders;
  final int totalReceivable;
  final int dueTodayCount;
  final int latePickupCount;
}

class UnpaidOrder {
  const UnpaidOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.queueNumber,
    required this.invoiceNumber,
    required this.service,
    required this.weightKg,
    required this.quantityPcs,
    required this.totalAmount,
    required this.paymentStatus,
    required this.fulfillment,
    required this.receivedAt,
    required this.estimatedCompletion,
    required this.binatuPic,
    required this.lateDays,
    required this.lateFee,
    this.deliveryDate,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String queueNumber;
  final String invoiceNumber;
  final UnpaidServiceType service;
  final double weightKg;
  final int quantityPcs;
  final int totalAmount;
  final UnpaidPaymentStatus paymentStatus;
  final UnpaidFulfillmentType fulfillment;
  final DateTime receivedAt;
  final DateTime estimatedCompletion;
  final DateTime? deliveryDate;
  final String binatuPic;
  final int lateDays;
  final int lateFee;

  bool get hasPickup => fulfillment == UnpaidFulfillmentType.pickup;

  bool get hasDelivery => fulfillment == UnpaidFulfillmentType.delivery;

  String get pickupLabel => hasPickup ? 'Ya' : 'Tidak';

  String get deliveryLabel => hasDelivery ? 'Ya' : 'Tidak';

  bool get isOverdue => lateDays > 0;

  bool get isDueToday {
    final now = DateTime.now();
    return estimatedCompletion.year == now.year &&
        estimatedCompletion.month == now.month &&
        estimatedCompletion.day == now.day;
  }

  Color get accentBarColor =>
      lateDays > 3 ? AppColors.accent : AppColors.primary;
}
