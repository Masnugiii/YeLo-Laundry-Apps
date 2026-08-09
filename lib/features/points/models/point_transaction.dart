import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

enum PointSource {
  orderLaundry,
  topUpDompet,
  promoMember,
  bonusUlangTahun,
  referral,
  manualAdjustment,
}

enum PointHistoryFilter {
  all,
  order,
  promo,
  topUp,
  referral,
  bonus,
}

extension PointHistoryFilterX on PointHistoryFilter {
  String get label => switch (this) {
        PointHistoryFilter.all => 'All',
        PointHistoryFilter.order => 'Order',
        PointHistoryFilter.promo => 'Promo',
        PointHistoryFilter.topUp => 'Top Up',
        PointHistoryFilter.referral => 'Referral',
        PointHistoryFilter.bonus => 'Bonus',
      };
}

extension PointSourceX on PointSource {
  String get label => switch (this) {
        PointSource.orderLaundry => 'Order Laundry',
        PointSource.topUpDompet => 'Top Up Dompet',
        PointSource.promoMember => 'Promo Member',
        PointSource.bonusUlangTahun => 'Bonus Ulang Tahun',
        PointSource.referral => 'Referral',
        PointSource.manualAdjustment => 'Manual Adjustment',
      };

  PointHistoryFilter get filterCategory => switch (this) {
        PointSource.orderLaundry => PointHistoryFilter.order,
        PointSource.topUpDompet => PointHistoryFilter.topUp,
        PointSource.promoMember => PointHistoryFilter.promo,
        PointSource.bonusUlangTahun => PointHistoryFilter.bonus,
        PointSource.referral => PointHistoryFilter.referral,
        PointSource.manualAdjustment => PointHistoryFilter.bonus,
      };

  bool get isBonusPoint => switch (this) {
        PointSource.orderLaundry => false,
        PointSource.topUpDompet => false,
        PointSource.promoMember => true,
        PointSource.bonusUlangTahun => true,
        PointSource.referral => true,
        PointSource.manualAdjustment => true,
      };

  Color get accentBarColor => isBonusPoint ? AppColors.accent : AppColors.primary;
}

class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.customerId,
    required this.date,
    required this.points,
    required this.source,
    required this.referenceNumber,
    required this.description,
  });

  final String id;
  final String customerId;
  final DateTime date;
  final int points;
  final PointSource source;
  final String referenceNumber;
  final String description;

  bool get isBonusPoint => source.isBonusPoint;

  String get formattedDate {
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
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String get formattedPoints {
    final prefix = points >= 0 ? '+' : '';
    return '$prefix$points Point';
  }
}
