enum NewOrderPaymentTiming {
  payNow,
  payLater,
}

extension NewOrderPaymentTimingX on NewOrderPaymentTiming {
  String get label => switch (this) {
        NewOrderPaymentTiming.payNow => 'Bayar Sekarang',
        NewOrderPaymentTiming.payLater => 'Bayar Nanti',
      };

  String get description => switch (this) {
        NewOrderPaymentTiming.payNow =>
          'Order dibuat lalu langsung diproses pembayaran.',
        NewOrderPaymentTiming.payLater =>
          'Order dibuat sebagai belum bayar dan dapat dibayar nanti.',
      };
}
