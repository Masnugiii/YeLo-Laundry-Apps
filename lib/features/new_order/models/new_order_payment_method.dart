enum NewOrderPaymentMethod {
  cash,
  qris,
  transfer,
}

extension NewOrderPaymentMethodX on NewOrderPaymentMethod {
  String get label => switch (this) {
        NewOrderPaymentMethod.cash => 'Cash',
        NewOrderPaymentMethod.qris => 'QRIS',
        NewOrderPaymentMethod.transfer => 'Transfer',
      };
}
