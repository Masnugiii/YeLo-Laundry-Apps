import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_payment_store.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_payment_bottom_sheet.dart';

class CashPaymentScreen extends StatefulWidget {
  const CashPaymentScreen({
    super.key,
    required this.session,
  });

  final OrderPaymentSession session;

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  final _amountController = TextEditingController();

  static const _dummyChangeAmount = 35000;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    final confirmation = buildPaymentConfirmation(
      session: widget.session,
      cashReceived: 100000,
      changeAmount: _dummyChangeAmount,
    );

    recordOrderPaymentToUangMasuk(
      order: widget.session.order,
      confirmation: confirmation,
    );

    await context.push('/order-payment-success', extra: confirmation);

    if (!mounted) return;
    context.pop(confirmation);
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
                  formatRupiah(_dummyChangeAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Perhitungan kembalian akan otomatis pada integrasi berikutnya.',
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
            onPressed: _confirmPayment,
            style: PaymentFlowTheme.primaryButtonStyle,
            child: Text(
              'Konfirmasi Pembayaran',
              style: PaymentFlowTheme.primaryButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
