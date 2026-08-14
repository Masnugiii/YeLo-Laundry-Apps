import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/payments/models/payment_transaction.dart'
    show PaymentMethod, PaymentPickupDelivery;

enum OrderPaymentMethod {
  cash,
  qris,
  transferBank,
  yeloWallet,
}

extension OrderPaymentMethodX on OrderPaymentMethod {
  String get label => switch (this) {
        OrderPaymentMethod.cash => 'Cash',
        OrderPaymentMethod.qris => 'QRIS',
        OrderPaymentMethod.transferBank => 'Transfer Bank',
        OrderPaymentMethod.yeloWallet => 'Yelo Wallet',
      };

  String get routeSuffix => switch (this) {
        OrderPaymentMethod.cash => 'cash',
        OrderPaymentMethod.qris => 'qris',
        OrderPaymentMethod.transferBank => 'transfer',
        OrderPaymentMethod.yeloWallet => 'wallet',
      };

  static List<OrderPaymentMethod> availableMethods({
    required bool yeloWalletEnabled,
  }) {
    return [
      OrderPaymentMethod.cash,
      OrderPaymentMethod.qris,
      OrderPaymentMethod.transferBank,
      if (yeloWalletEnabled) OrderPaymentMethod.yeloWallet,
    ];
  }

  PaymentMethod toPaymentMethod() => switch (this) {
        OrderPaymentMethod.cash => PaymentMethod.cash,
        OrderPaymentMethod.qris => PaymentMethod.qris,
        OrderPaymentMethod.transferBank => PaymentMethod.transfer,
        OrderPaymentMethod.yeloWallet => PaymentMethod.yeloWallet,
      };
}

/// Carries order context through the POS payment flow (Step 1 → Step 2 → Step 3).
class OrderPaymentSession {
  const OrderPaymentSession({
    required this.order,
    required this.paymentMethod,
    required this.yeloWalletEnabled,
  });

  final IncomingOrder order;
  final OrderPaymentMethod paymentMethod;
  final bool yeloWalletEnabled;
}

class OrderPaymentConfirmation {
  const OrderPaymentConfirmation({
    required this.orderId,
    required this.customerName,
    required this.queueNumber,
    required this.service,
    required this.weightKg,
    required this.totalPayment,
    required this.paymentMethod,
    required this.paidAt,
    this.paymentStatus = 'Lunas',
    this.cashReceived,
    this.changeAmount,
    this.walletBalanceBefore,
    this.walletBalanceAfter,
  });

  final String orderId;
  final String customerName;
  final String queueNumber;
  final LaundryServiceType service;
  final double weightKg;
  final int totalPayment;
  final OrderPaymentMethod paymentMethod;
  final DateTime paidAt;
  final String paymentStatus;
  final int? cashReceived;
  final int? changeAmount;
  final int? walletBalanceBefore;
  final int? walletBalanceAfter;

  String get serviceLabel => service.label;

  String get paymentMethodLabel => paymentMethod.label;

  String get paymentTimeLabel => formatPaymentTime(paidAt);
}

PaymentPickupDelivery fulfillmentToPaymentPickup(FulfillmentType type) {
  return switch (type) {
    FulfillmentType.selfPickup => PaymentPickupDelivery.datangSendiri,
    FulfillmentType.pickup => PaymentPickupDelivery.jemput,
    FulfillmentType.delivery => PaymentPickupDelivery.antar,
  };
}

String formatPaymentTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}
