import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/services/order_payment_service.dart';

class QrisPaymentScreen extends ConsumerStatefulWidget {
  const QrisPaymentScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  @override
  ConsumerState<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends ConsumerState<QrisPaymentScreen> {
  bool _isSubmitting = false;

  Future<void> _completePayment() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final confirmation = await ref
          .read(orderPaymentServiceProvider)
          .submitPayment(widget.session);

      if (!mounted) return;

      await context.push('/order-payment-success', extra: confirmation);

      if (!mounted) return;
      context.pop(confirmation);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          content: Text(
            error.message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          content: Text(
            'Gagal memproses pembayaran. Silakan coba lagi.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
          'QRIS Payment',
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
                Text(
                  'QRIS Payment',
                  style: PaymentFlowTheme.sectionTitleStyle,
                ),
                const SizedBox(height: AppSpacing.s20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.dashboardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'QR Code Placeholder',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Status: Menunggu Pembayaran...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Refresh Status',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          FilledButton(
            onPressed: _isSubmitting ? null : _completePayment,
            style: PaymentFlowTheme.primaryButtonStyle,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(
                    'Konfirmasi Pembayaran',
                    style: PaymentFlowTheme.primaryButtonTextStyle,
                  ),
          ),
        ],
      ),
    );
  }
}
