enum WalletTopUpPaymentMethod {
  cash,
  qris,
  transfer,
}

extension WalletTopUpPaymentMethodX on WalletTopUpPaymentMethod {
  String get label => switch (this) {
        WalletTopUpPaymentMethod.cash => 'Cash',
        WalletTopUpPaymentMethod.qris => 'QRIS',
        WalletTopUpPaymentMethod.transfer => 'Transfer',
      };
}

/// Foundation model for future wallet top-up audit history.
class WalletTopUpRecord {
  const WalletTopUpRecord({
    required this.adminName,
    required this.paymentMethod,
    required this.amount,
    required this.dateTime,
    required this.customerId,
  });

  final String adminName;
  final WalletTopUpPaymentMethod paymentMethod;
  final int amount;
  final DateTime dateTime;
  final String customerId;
}
