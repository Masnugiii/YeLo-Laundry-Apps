class WalletPaymentConfirmation {
  const WalletPaymentConfirmation({
    required this.customerId,
    required this.customerName,
    required this.initialBalance,
    required this.deductionAmount,
    required this.finalBalance,
    required this.adminName,
    required this.deductionReason,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.dateTime,
  });

  final String customerId;
  final String customerName;
  final int initialBalance;
  final int deductionAmount;
  final int finalBalance;
  final String adminName;
  final String deductionReason;
  final String paymentMethod;
  final String referenceNumber;
  final DateTime dateTime;

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

  static String dummyReferenceNumber(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return 'YW-WALLET-$year$month$day-0001';
  }
}
