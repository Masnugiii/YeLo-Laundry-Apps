enum CashierNotificationType {
  cashPayment,
  qrisPayment,
  transferPayment,
  walletTopUp,
  walletDeduction,
}

extension CashierNotificationTypeX on CashierNotificationType {
  String get title => switch (this) {
        CashierNotificationType.cashPayment => 'Cash Payment Success',
        CashierNotificationType.qrisPayment => 'QRIS Payment Success',
        CashierNotificationType.transferPayment => 'Transfer Payment Success',
        CashierNotificationType.walletTopUp => 'Wallet Top Up Success',
        CashierNotificationType.walletDeduction => 'Wallet Balance Deduction Success',
      };

  String get iconLabel => switch (this) {
        CashierNotificationType.cashPayment => 'CASH',
        CashierNotificationType.qrisPayment => 'QRIS',
        CashierNotificationType.transferPayment => 'TRF',
        CashierNotificationType.walletTopUp => 'TOP UP',
        CashierNotificationType.walletDeduction => 'WALLET',
      };
}

class CashierTransactionNotification {
  const CashierTransactionNotification({
    required this.id,
    required this.type,
    required this.customerName,
    required this.amount,
    required this.transactionAt,
    this.orderNumber,
    this.paymentMethod,
    this.transactionNumber,
  });

  final String id;
  final CashierNotificationType type;
  final String customerName;
  final int amount;
  final DateTime transactionAt;
  final String? orderNumber;
  final String? paymentMethod;
  final String? transactionNumber;

  bool get showsPaymentMethod =>
      type == CashierNotificationType.cashPayment && paymentMethod != null;

  bool get showsOrderNumber =>
      type == CashierNotificationType.cashPayment ||
      type == CashierNotificationType.qrisPayment ||
      type == CashierNotificationType.transferPayment;

  bool get showsTransactionNumber =>
      type == CashierNotificationType.walletTopUp ||
      type == CashierNotificationType.walletDeduction;
}
