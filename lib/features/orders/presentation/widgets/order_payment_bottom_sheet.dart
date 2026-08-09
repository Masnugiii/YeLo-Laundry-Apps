import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/widgets/payment_summary_section.dart';

Future<OrderPaymentSession?> showOrderPaymentBottomSheet(
  BuildContext context, {
  required IncomingOrder order,
  required bool yeloWalletEnabled,
}) {
  return showModalBottomSheet<OrderPaymentSession>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _OrderPaymentBottomSheet(
      order: order,
      yeloWalletEnabled: yeloWalletEnabled,
    ),
  );
}

class _OrderPaymentBottomSheet extends StatefulWidget {
  const _OrderPaymentBottomSheet({
    required this.order,
    required this.yeloWalletEnabled,
  });

  final IncomingOrder order;
  final bool yeloWalletEnabled;

  @override
  State<_OrderPaymentBottomSheet> createState() =>
      _OrderPaymentBottomSheetState();
}

class _OrderPaymentBottomSheetState extends State<_OrderPaymentBottomSheet> {
  late OrderPaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = OrderPaymentMethodX.availableMethods(
      yeloWalletEnabled: widget.yeloWalletEnabled,
    ).first;
  }

  void _continue() {
    Navigator.of(context).pop(
      OrderPaymentSession(
        order: widget.order,
        paymentMethod: _selectedMethod,
        yeloWalletEnabled: widget.yeloWalletEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final methods = OrderPaymentMethodX.availableMethods(
      yeloWalletEnabled: widget.yeloWalletEnabled,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Lanjutkan Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            PaymentSummarySection(order: widget.order),
            const SizedBox(height: AppSpacing.s20),
            Text(
              'Metode Pembayaran',
              style: PaymentFlowTheme.sectionTitleStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.s8),
            RadioGroup<OrderPaymentMethod>(
              groupValue: _selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
              child: Column(
                children: [
                  for (final method in methods)
                    RadioListTile<OrderPaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        method.label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      value: method,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            FilledButton(
              onPressed: _continue,
              style: PaymentFlowTheme.primaryButtonStyle,
              child: Text('Lanjutkan', style: PaymentFlowTheme.primaryButtonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}

OrderPaymentConfirmation buildPaymentConfirmation({
  required OrderPaymentSession session,
  int? cashReceived,
  int? changeAmount,
  int? walletBalanceBefore,
  int? walletBalanceAfter,
}) {
  return OrderPaymentConfirmation(
    orderId: session.order.id,
    customerName: session.order.customerName,
    queueNumber: session.order.queueNumber,
    service: session.order.service,
    weightKg: session.order.weightKg,
    totalPayment: session.order.orderValue,
    paymentMethod: session.paymentMethod,
    paidAt: DateTime.now(),
    cashReceived: cashReceived,
    changeAmount: changeAmount,
    walletBalanceBefore: walletBalanceBefore,
    walletBalanceAfter: walletBalanceAfter,
  );
}
