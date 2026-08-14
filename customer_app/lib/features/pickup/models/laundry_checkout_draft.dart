import 'package:yelo_laundry_customer/features/catalog/data/laundry_catalog_service.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_perfume_option.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_address_input.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_status.dart';

class LaundryCheckoutLine {
  const LaundryCheckoutLine({
    required this.service,
    required this.quantity,
  });

  final LaundryCatalogService service;
  final int quantity;

  int get subtotal => service.lineTotal(quantity);
}

class LaundryCheckoutDraft {
  LaundryCheckoutDraft({
    required this.services,
    required this.quantities,
    this.pickup = const CheckoutAddressInput(),
    this.delivery = const CheckoutAddressInput(),
    this.selectedPerfume = LaundryPerfumeOption.none,
    this.notes = '',
    this.scheduledAt,
    this.paymentMethodCode = CheckoutPaymentMethods.yeloWallet,
    this.walletBalance,
  });

  final List<LaundryCatalogService> services;
  final Map<String, int> quantities;
  final CheckoutAddressInput pickup;
  final CheckoutAddressInput delivery;
  final LaundryPerfumeOption selectedPerfume;
  final String notes;
  final DateTime? scheduledAt;
  final String paymentMethodCode;
  final double? walletBalance;

  List<LaundryCheckoutLine> get lines {
    return [
      for (final service in services)
        if ((quantities[service.id] ?? 0) > 0)
          LaundryCheckoutLine(
            service: service,
            quantity: quantities[service.id]!,
          ),
    ];
  }

  int get servicesSubtotal =>
      lines.fold(0, (sum, line) => sum + line.subtotal);

  /// Delivery fee is not configured in backend yet.
  int? get deliveryFee => null;

  int get perfumeFee => selectedPerfume.extraPrice ?? 0;

  int get grandTotal =>
      servicesSubtotal + perfumeFee + (deliveryFee ?? 0);

  String get perfumeLabel => selectedPerfume.name;

  bool get isValidForPayment =>
      lines.isNotEmpty && pickup.isFilled && delivery.isFilled;
}

class LaundryCheckoutResult {
  const LaundryCheckoutResult({
    required this.orderId,
    required this.orderNumber,
    required this.paymentStatus,
    required this.grandTotal,
    required this.pickup,
    required this.delivery,
    required this.selectedPerfume,
    required this.lines,
    required this.paymentMethodLabel,
    required this.usePickupDelivery,
  });

  final String orderId;
  final String orderNumber;
  final CheckoutPaymentStatus paymentStatus;
  final int grandTotal;
  final CheckoutAddressInput pickup;
  final CheckoutAddressInput delivery;
  final LaundryPerfumeOption selectedPerfume;
  final List<LaundryCheckoutLine> lines;
  final String paymentMethodLabel;
  final bool usePickupDelivery;
}

class CheckoutApiException implements Exception {
  CheckoutApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
