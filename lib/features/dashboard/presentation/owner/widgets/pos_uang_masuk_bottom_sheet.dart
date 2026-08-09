import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/payments/presentation/widgets/payment_transaction_card.dart';
import 'package:yelo_laundry_erp/features/payments/theme/payment_colors.dart';
import 'package:yelo_laundry_erp/features/reports/providers/reports_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

void showUangMasukBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.dashboardBackground,
    builder: (context) => const _UangMasukBottomSheet(),
  );
}

class _UangMasukBottomSheet extends ConsumerWidget {
  const _UangMasukBottomSheet();

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(todayPaymentsProvider);
    final historyAsync = ref.watch(todayPaymentHistoryProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    final history =
        historyAsync.hasValue ? historyAsync.requireValue : const <String, dynamic>{};
    final totalToday = ((history['cash'] as num?) ?? 0) +
        ((history['qris'] as num?) ?? 0) +
        ((history['transfer'] as num?) ?? 0) +
        ((history['wallet'] as num?) ?? 0);

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
                historyAsync.when(
                  loading: () => const SizedBox(
                    height: 36,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: PaymentColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Rp0',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: PaymentColors.onPrimary,
                    ),
                  ),
                  data: (_) => Text(
                    _formatCurrency(totalToday),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: PaymentColors.onPrimary,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                historyAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (data) => _PaymentSummarySection(
                    cash: _formatCurrency((data['cash'] as num?) ?? 0),
                    qris: _formatCurrency((data['qris'] as num?) ?? 0),
                    transfer: _formatCurrency((data['transfer'] as num?) ?? 0),
                  ),
                ),
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
            child: paymentsAsync.when(
              loading: () => const ApiLoadingView(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () => ref.invalidate(todayPaymentsProvider),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada pembayaran hari ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return PaymentTransactionCard(
                      transaction: transactions[index],
                    );
                  },
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
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/reports');
                },
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
  const _PaymentSummarySection({
    required this.cash,
    required this.qris,
    required this.transfer,
  });

  final String cash;
  final String qris;
  final String transfer;

  static const _dividerColor = Color(0x40FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: _dividerColor),
        const SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'Cash', amount: cash),
        const SizedBox(height: AppSpacing.s12),
        const Divider(height: 1, thickness: 1, color: _dividerColor),
        const SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'QRIS', amount: qris),
        const SizedBox(height: AppSpacing.s12),
        const Divider(height: 1, thickness: 1, color: _dividerColor),
        const SizedBox(height: AppSpacing.s12),
        _PaymentMethodRow(label: 'Transfer', amount: transfer),
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
