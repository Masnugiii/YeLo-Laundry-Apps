import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/services/order_payment_service.dart';

class CashPaymentScreen extends ConsumerStatefulWidget {
  const CashPaymentScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  @override
  ConsumerState<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends ConsumerState<CashPaymentScreen> {
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  int get _cashReceived =>
      int.tryParse(_amountController.text.trim()) ?? 0;

  int get _changeAmount =>
      _cashReceived > widget.session.order.orderValue
          ? _cashReceived - widget.session.order.orderValue
          : 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    if (_isSubmitting) return;

    final cashReceived = _cashReceived;
    if (cashReceived < widget.session.order.orderValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          content: Text(
            'Nominal uang customer kurang dari total tagihan.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final confirmation = await ref
          .read(orderPaymentServiceProvider)
          .submitPayment(
            widget.session,
            cashReceived: cashReceived,
          );

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
    final total = widget.session.order.orderValue;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Cash Payment',
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
                Text('Total Tagihan', style: PaymentFlowTheme.labelStyle),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  formatRupiah(total),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Nominal Uang Customer',
                  style: PaymentFlowTheme.labelStyle,
                ),
                const SizedBox(height: AppSpacing.s8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nominal uang customer',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.dashboardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text('Kembalian', style: PaymentFlowTheme.labelStyle),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  formatRupiah(_changeAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          FilledButton(
            onPressed: _isSubmitting ? null : _confirmPayment,
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
