import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/widgets/payment_summary_section.dart';

class OrderPaymentReviewScreen extends StatelessWidget {
  const OrderPaymentReviewScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  Future<void> _processPayment(BuildContext context) async {
    final result = await context.push<OrderPaymentConfirmation>(
      '/order-payment/${session.paymentMethod.routeSuffix}',
      extra: session,
    );

    if (context.mounted && result != null) {
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Review Payment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          PaymentSummarySection(
            order: session.order,
            paymentMethod: session.paymentMethod,
            showPaymentMethod: true,
          ),
          const SizedBox(height: AppSpacing.s24),
          FilledButton(
            onPressed: () => _processPayment(context),
            style: PaymentFlowTheme.primaryButtonStyle,
            child: Text(
              'Proses Pembayaran',
              style: PaymentFlowTheme.primaryButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
