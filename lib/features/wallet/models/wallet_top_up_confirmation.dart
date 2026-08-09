import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up.dart';

class WalletTopUpConfirmation {
  const WalletTopUpConfirmation({
    required this.customerId,
    required this.customerName,
    required this.initialBalance,
    required this.topUpAmount,
    required this.finalBalance,
    required this.adminName,
    required this.paymentMethod,
    required this.dateTime,
  });

  final String customerId;
  final String customerName;
  final int initialBalance;
  final int topUpAmount;
  final int finalBalance;
  final String adminName;
  final WalletTopUpPaymentMethod paymentMethod;
  final DateTime dateTime;

  String get paymentMethodLabel => paymentMethod.label;

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
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
