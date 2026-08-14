import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

abstract final class WalletTransactionFormat {
  static bool isIncome(WalletTransaction item) {
    if (item.amount > 0) return true;
    const incomeTypes = {
      'top_up',
      'TOPUP',
      'refund',
      'promotion',
      'manual_credit',
    };
    return incomeTypes.contains(item.type.toLowerCase()) ||
        incomeTypes.contains(item.type);
  }

  static String title(WalletTransaction item) {
    switch (item.type.toLowerCase()) {
      case 'top_up':
      case 'topup':
        return 'Top Up Wallet';
      case 'deduction':
      case 'payment':
        return 'Pembayaran Laundry';
      case 'refund':
        return 'Pengembalian dana';
      case 'promotion':
        return 'Promo';
      default:
        return item.type.replaceAll('_', ' ').toUpperCase();
    }
  }

  static String amountLabel(
    WalletTransaction item,
    NumberFormat currency,
  ) {
    final income = isIncome(item);
    final amount = item.amount.abs();
    if (income) {
      return '+ ${currency.format(amount)}';
    }
    return '- ${currency.format(amount)}';
  }

  static DateTime? parseDate(String value) => DateTime.tryParse(value);
}
