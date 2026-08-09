import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';

class WalletTopUpReceipt {
  const WalletTopUpReceipt({
    required this.transactionNumber,
    required this.transactionDate,
    required this.transactionTime,
    required this.customerName,
    required this.phoneNumber,
    required this.balanceBefore,
    required this.topUpAmount,
    required this.balanceAfter,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.adminName,
    this.footerNote =
        'Terima kasih telah melakukan Top Up Yelo Wallet.\n\n'
        'Saldo Anda telah berhasil diperbarui.',
    this.bottomNote =
        'Gunakan saldo Yelo Wallet untuk pembayaran laundry yang lebih cepat dan praktis.',
  });

  final String transactionNumber;
  final String transactionDate;
  final String transactionTime;
  final String customerName;
  final String phoneNumber;
  final int balanceBefore;
  final int topUpAmount;
  final int balanceAfter;
  final String paymentMethod;
  final String paymentStatus;
  final String adminName;
  final String footerNote;
  final String bottomNote;

  factory WalletTopUpReceipt.fromConfirmation(
    WalletTopUpConfirmation confirmation, {
    String? phoneNumber,
    String paymentStatus = 'Lunas',
  }) {
    return WalletTopUpReceipt(
      transactionNumber: formatTransactionNumber(confirmation.dateTime),
      transactionDate: confirmation.formattedDate,
      transactionTime: '${confirmation.formattedTime} WIB',
      customerName: confirmation.customerName,
      phoneNumber: phoneNumber ?? '081234567890',
      balanceBefore: confirmation.initialBalance,
      topUpAmount: confirmation.topUpAmount,
      balanceAfter: confirmation.finalBalance,
      paymentMethod: confirmation.paymentMethodLabel,
      paymentStatus: paymentStatus,
      adminName: confirmation.adminName,
    );
  }

  static String formatTransactionNumber(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return 'WU-$year$month$day-00001';
  }
}

enum WalletTopUpReceiptPaperWidth {
  mm58,
  mm80,
}
