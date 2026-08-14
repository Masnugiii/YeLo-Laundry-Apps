import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';

class WalletDeductionReceipt {
  const WalletDeductionReceipt({
    required this.transactionNumber,
    required this.transactionDate,
    required this.transactionTime,
    required this.customerName,
    required this.phoneNumber,
    required this.balanceBefore,
    required this.deductionAmount,
    required this.balanceAfter,
    required this.reason,
    required this.cashierName,
    this.relatedOrder,
    this.footerNote =
        'Terima kasih telah menggunakan Yelo Wallet.\n\n'
        'Saldo Anda telah berhasil diperbarui.',
  });

  final String transactionNumber;
  final String transactionDate;
  final String transactionTime;
  final String customerName;
  final String phoneNumber;
  final int balanceBefore;
  final int deductionAmount;
  final int balanceAfter;
  final String reason;
  final String? relatedOrder;
  final String cashierName;
  final String footerNote;

  factory WalletDeductionReceipt.fromConfirmation(
    WalletPaymentConfirmation confirmation, {
    String? phoneNumber,
    String? relatedOrder,
  }) {
    return WalletDeductionReceipt(
      transactionNumber: formatTransactionNumber(confirmation.dateTime),
      transactionDate: confirmation.formattedDate,
      transactionTime: '${confirmation.formattedTime} WIB',
      customerName: confirmation.customerName,
      phoneNumber: phoneNumber ?? '081234567890',
      balanceBefore: confirmation.initialBalance,
      deductionAmount: confirmation.deductionAmount,
      balanceAfter: confirmation.finalBalance,
      reason: confirmation.deductionReason,
      relatedOrder: relatedOrder,
      cashierName: confirmation.adminName,
    );
  }

  static String formatTransactionNumber(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return 'WD-$year$month$day-00001';
  }
}

enum WalletDeductionReceiptPaperWidth {
  mm58,
  mm80,
}
