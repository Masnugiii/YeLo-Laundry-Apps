import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/providers/order_list_provider.dart';
import 'package:yelo_laundry_erp/features/orders/providers/order_query_providers.dart';

class OrderPaymentService {
  OrderPaymentService(this._ref);

  final Ref _ref;

  Future<OrderPaymentConfirmation> submitPayment(
    OrderPaymentSession session, {
    int? cashReceived,
    int? walletBalanceBefore,
    int? walletBalanceAfter,
  }) async {
    final response = await _ref.read(financeRepositoryProvider).createPayment({
      'orderId': session.order.id,
      'paymentMethod': _mapPaymentMethod(session.paymentMethod),
      'amount': session.order.orderValue.toDouble(),
      'paymentStatus': 'PAID',
    });

    final paidAt = DateTime.tryParse(response['paidAt'] as String? ?? '') ??
        DateTime.now();

    int? changeAmount;
    if (cashReceived != null) {
      changeAmount = cashReceived - session.order.orderValue;
    }

    final confirmation = OrderPaymentConfirmation(
      orderId: session.order.id,
      customerName: session.order.customerName,
      queueNumber: session.order.queueNumber,
      service: session.order.service,
      weightKg: session.order.weightKg,
      totalPayment: session.order.orderValue,
      paymentMethod: session.paymentMethod,
      paidAt: paidAt,
      cashReceived: cashReceived,
      changeAmount: changeAmount,
      walletBalanceBefore: walletBalanceBefore,
      walletBalanceAfter: walletBalanceAfter,
    );

    _ref.invalidate(orderListProvider);
    _ref.invalidate(unpaidOrdersProvider);
    _ref.invalidate(todayOrdersProvider);

    return confirmation;
  }

  String _mapPaymentMethod(OrderPaymentMethod method) {
    return switch (method) {
      OrderPaymentMethod.cash => 'CASH',
      OrderPaymentMethod.qris => 'QRIS',
      OrderPaymentMethod.transferBank => 'BANK_TRANSFER',
      OrderPaymentMethod.yeloWallet => 'CUSTOMER_WALLET',
    };
  }
}

final orderPaymentServiceProvider = Provider<OrderPaymentService>((ref) {
  return OrderPaymentService(ref);
});
