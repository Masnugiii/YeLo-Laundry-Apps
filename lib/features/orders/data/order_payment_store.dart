import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/payments/data/dummy_payment_transactions.dart';
import 'package:yelo_laundry_erp/features/payments/models/payment_transaction.dart'
    as payments;

/// UI-only store prepared for future payment synchronization.
void recordOrderPaymentToUangMasuk({
  required IncomingOrder order,
  required OrderPaymentConfirmation confirmation,
}) {
  final transaction = payments.PaymentTransaction(
    customerName: confirmation.customerName,
    queueNumber: confirmation.queueNumber,
    service: _mapService(confirmation.service),
    weightKg: confirmation.weightKg,
    totalPayment: formatRupiah(confirmation.totalPayment),
    paymentMethod: confirmation.paymentMethod.toPaymentMethod(),
    pickupDelivery: fulfillmentToPaymentPickup(order.fulfillmentType),
    laundryStatus: payments.PaymentLaundryStatus.selesai,
    paymentTime: formatPaymentTime(confirmation.paidAt),
    paidAt: confirmation.paidAt,
  );

  dummyPaymentTransactions.insert(0, transaction);
}

payments.LaundryServiceType _mapService(LaundryServiceType service) {
  return switch (service) {
    LaundryServiceType.regular => payments.LaundryServiceType.regular,
    LaundryServiceType.express => payments.LaundryServiceType.express,
    LaundryServiceType.bedCover => payments.LaundryServiceType.bedCover,
    LaundryServiceType.ironOnly => payments.LaundryServiceType.ironOnly,
  };
}
