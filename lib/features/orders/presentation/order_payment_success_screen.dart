import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/widgets/payment_summary_section.dart';

class OrderPaymentSuccessScreen extends StatelessWidget {
  const OrderPaymentSuccessScreen({
    super.key,
    required this.confirmation,
  });

  final OrderPaymentConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s32,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Text(
                'Pembayaran Berhasil',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Pembayaran telah diterima.\nTransaksi berhasil diselesaikan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: PaymentFlowTheme.cardDecoration,
                child: Column(
                  children: [
                    PaymentInfoRow(
                      label: 'Customer Name',
                      value: confirmation.customerName,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Queue Number',
                      value: confirmation.queueNumber,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Laundry Service',
                      value: confirmation.serviceLabel,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Laundry Weight',
                      value: '${confirmation.weightKg} kg',
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Payment Method',
                      value: confirmation.paymentMethodLabel,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Total Payment',
                      value: formatRupiah(confirmation.totalPayment),
                      emphasized: true,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Payment Status',
                      value: confirmation.paymentStatus,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    PaymentInfoRow(
                      label: 'Payment Time',
                      value: confirmation.paymentTimeLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              _ActionButton(
                label: 'Cetak Struk',
                backgroundColor: AppColors.primary,
                textColor: AppColors.onPrimary,
                onPressed: () => context.push('/laundry-receipt'),
              ),
              const SizedBox(height: AppSpacing.s12),
              _ActionButton(
                label: 'Bagikan Struk ke WhatsApp',
                backgroundColor: const Color(0xFF25D366),
                textColor: AppColors.onPrimary,
                onPressed: () => context.push('/laundry-receipt'),
              ),
              const SizedBox(height: AppSpacing.s12),
              _ActionButton(
                label: 'Simpan PDF',
                backgroundColor: AppColors.surface,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                onPressed: () => context.push('/laundry-receipt'),
              ),
              const SizedBox(height: AppSpacing.s12),
              _ActionButton(
                label: 'Selesai',
                backgroundColor: AppColors.surface,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                onPressed: () => context.pop(confirmation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1.5)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
