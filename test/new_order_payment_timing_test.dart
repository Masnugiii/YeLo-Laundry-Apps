import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_erp/features/new_order/models/new_order_payment_timing.dart';

void main() {
  group('NewOrderPaymentTiming', () {
    test('has pay now and pay later options', () {
      expect(NewOrderPaymentTiming.values, hasLength(2));
      expect(NewOrderPaymentTiming.payNow.label, 'Bayar Sekarang');
      expect(NewOrderPaymentTiming.payLater.label, 'Bayar Nanti');
    });
  });
}
