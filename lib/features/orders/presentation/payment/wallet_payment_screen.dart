import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_payment_store.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/widgets/payment_summary_section.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_payment_bottom_sheet.dart';

class WalletPaymentScreen extends StatelessWidget {
  const WalletPaymentScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  Future<void> _completePayment(BuildContext context) async {
    final total = session.order.orderValue;
    final confirmation = buildPaymentConfirmation(
      session: session,
      walletBalanceBefore: dummyCustomerWalletBalance,
      walletBalanceAfter: dummyCustomerWalletBalance - total,
    );

    recordOrderPaymentToUangMasuk(
      order: session.order,
      confirmation: confirmation,
    );

    await context.push('/order-payment-success', extra: confirmation);

    if (context.mounted) {
      context.pop(confirmation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = session.order.orderValue;
    final remaining = dummyCustomerWalletBalance - total;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Yelo Wallet',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: PaymentFlowTheme.cardDecoration,
            child: Column(
              children: [
                PaymentInfoRow(
                  label: 'Current Wallet Balance',
                  value: formatRupiah(dummyCustomerWalletBalance),
                ),
                const SizedBox(height: AppSpacing.s12),
                PaymentInfoRow(
                  label: 'Total Payment',
                  value: formatRupiah(total),
                ),
                const Divider(height: AppSpacing.s24),
                PaymentInfoRow(
                  label: 'Remaining Balance',
                  value: formatRupiah(remaining),
                  emphasized: true,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Potong saldo dompet akan diintegrasikan pada versi berikutnya.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          FilledButton(
            onPressed: () => _completePayment(context),
            style: PaymentFlowTheme.primaryButtonStyle,
            child: Text(
              'Potong Saldo Dompet',
              style: PaymentFlowTheme.primaryButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
