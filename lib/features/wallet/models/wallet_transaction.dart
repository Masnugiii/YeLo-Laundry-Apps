import 'package:flutter/material.dart';

enum WalletTransactionType {
  topUp,
  payment,
  refund,
  adjustment,
}

extension WalletTransactionTypeX on WalletTransactionType {
  String get label => switch (this) {
        WalletTransactionType.topUp => 'Top Up',
        WalletTransactionType.payment => 'Pembayaran Laundry',
        WalletTransactionType.refund => 'Refund',
        WalletTransactionType.adjustment => 'Penyesuaian',
      };

  Color get amountColor => switch (this) {
        WalletTransactionType.topUp => const Color(0xFF22C55E),
        WalletTransactionType.payment => const Color(0xFF033B8E),
        WalletTransactionType.refund => const Color(0xFFF59E0B),
        WalletTransactionType.adjustment => const Color(0xFFDC2626),
      };
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.customerId,
    required this.date,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    this.adminName,
    this.deductionReason,
  });

  final String id;
  final String customerId;
  final DateTime date;
  final WalletTransactionType type;
  final int amount;
  final int balanceAfter;
  final String? note;
  final String? adminName;
  final String? deductionReason;

  bool get isCredit => amount > 0;

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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
