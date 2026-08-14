import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_payment_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';

/// Starts the existing POS payment flow for an unpaid order.
///
/// Returns a payment confirmation when the flow completes successfully.
Future<OrderPaymentConfirmation?> launchOrderPaymentFlow(
  BuildContext context, {
  required IncomingOrder order,
  bool? yeloWalletEnabled,
}) async {
  final walletEnabled =
      yeloWalletEnabled ?? initialAppSettings.yeloWalletEnabled;

  final session = await showOrderPaymentBottomSheet(
    context,
    order: order,
    yeloWalletEnabled: walletEnabled,
  );

  if (!context.mounted || session == null) {
    return null;
  }

  return context.push<OrderPaymentConfirmation>(
    '/order-payment/review',
    extra: session,
  );
}
