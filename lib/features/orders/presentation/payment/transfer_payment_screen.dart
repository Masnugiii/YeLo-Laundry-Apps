import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_payment_store.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/widgets/payment_summary_section.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_payment_bottom_sheet.dart';

class TransferPaymentScreen extends StatelessWidget {
  const TransferPaymentScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  Future<void> _completePayment(BuildContext context) async {
    final confirmation = buildPaymentConfirmation(session: session);

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
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Transfer Bank',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Bank',
                  style: PaymentFlowTheme.sectionTitleStyle,
                ),
                const SizedBox(height: AppSpacing.s16),
                PaymentInfoRow(
                  label: 'Bank',
                  value: dummyTransferBankName,
                ),
                const SizedBox(height: AppSpacing.s8),
                PaymentInfoRow(
                  label: 'Account Number',
                  value: dummyTransferAccountNumber,
                ),
                const SizedBox(height: AppSpacing.s8),
                PaymentInfoRow(
                  label: 'Account Name',
                  value: dummyTransferAccountName,
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Status: Menunggu Konfirmasi Pembayaran',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
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
              'Saya Sudah Menerima Transfer',
              style: PaymentFlowTheme.primaryButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
