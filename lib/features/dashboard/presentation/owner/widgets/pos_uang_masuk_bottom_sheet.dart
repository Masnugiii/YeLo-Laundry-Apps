import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/payments/data/dummy_payment_transactions.dart';
import 'package:yelo_laundry_erp/features/payments/presentation/widgets/payment_transaction_card.dart';
import 'package:yelo_laundry_erp/features/payments/theme/payment_colors.dart';

void showUangMasukBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.dashboardBackground,
    builder: (context) => const _UangMasukBottomSheet(),
  );
}

class _UangMasukBottomSheet extends StatelessWidget {
  const _UangMasukBottomSheet();

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: PaymentColors.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PaymentColors.onPrimary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Uang Masuk Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: PaymentColors.onPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  totalUangMasukHariIni,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: PaymentColors.onPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                const _PaymentSummarySection(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: Text(
              'Transaksi Hari Ini',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              itemCount: dummyPaymentTransactions.length,
              itemBuilder: (context, index) {
                return PaymentTransactionCard(
                  transaction: dummyPaymentTransactions[index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s8,
              AppSpacing.s20,
              AppSpacing.s24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
              onPressed: () {},
              child: Text(
                'Lihat Laporan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummarySection extends StatelessWidget {
  const _PaymentSummarySection();

  static const _dividerColor = Color(0x40FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Divider(height: 1, thickness: 1, color: _dividerColor),
        SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'Cash', amount: paymentSummaryCash),
        SizedBox(height: AppSpacing.s12),
        Divider(height: 1, thickness: 1, color: _dividerColor),
        SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'QRIS', amount: paymentSummaryQris),
        SizedBox(height: AppSpacing.s12),
        Divider(height: 1, thickness: 1, color: _dividerColor),
        SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'Transfer', amount: paymentSummaryTransfer),
      ],
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    required this.label,
    required this.amount,
  });

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: PaymentColors.onPrimary,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: PaymentColors.onPrimary,
          ),
        ),
      ],
    );
  }
}
