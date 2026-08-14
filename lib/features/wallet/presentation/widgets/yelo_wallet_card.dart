import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_transaction.dart';

class YeloWalletCard extends StatelessWidget {
  const YeloWalletCard({
    super.key,
    required this.wallet,
    required this.transactions,
    required this.onHistoryPressed,
    this.onTopUpPressed,
    this.onDeductPressed,
    this.transactionsLoading = false,
  });

  final CustomerWalletSummary wallet;
  final List<WalletTransaction> transactions;
  final VoidCallback onHistoryPressed;
  final VoidCallback? onTopUpPressed;
  final VoidCallback? onDeductPressed;
  final bool transactionsLoading;

  @override
  Widget build(BuildContext context) {
    final recent = transactions.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YeLo Wallet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Saldo Saat Ini',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            formatRupiah(wallet.balance.round()),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: _WalletStat(
                  label: 'Total Deposit',
                  value: formatRupiah(wallet.totalTopup.round()),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _WalletStat(
                  label: 'Total Penggunaan',
                  value: formatRupiah(wallet.totalSpending.round()),
                ),
              ),
            ],
          ),
          if (onTopUpPressed != null || onDeductPressed != null) ...[
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                if (onTopUpPressed != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Tambah Saldo',
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.onPrimary,
                      onPressed: onTopUpPressed,
                    ),
                  ),
                if (onTopUpPressed != null && onDeductPressed != null)
                  const SizedBox(width: AppSpacing.s8),
                if (onDeductPressed != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Kurangi Saldo',
                      backgroundColor: AppColors.surface,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      onPressed: onDeductPressed,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              label: 'Riwayat Wallet',
              backgroundColor: AppColors.accent,
              textColor: AppColors.primary,
              onPressed: onHistoryPressed,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Riwayat transaksi',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (transactionsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            Text(
              'Belum ada riwayat transaksi',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            for (var i = 0; i < recent.length; i++) ...[
              _WalletHistoryRow(transaction: recent[i]),
              if (i < recent.length - 1) ...[
                const SizedBox(height: AppSpacing.s12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.s12),
              ],
            ],
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  const _WalletStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletHistoryRow extends StatelessWidget {
  const _WalletHistoryRow({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final amountPrefix = transaction.isCredit ? '+ ' : '- ';
    final meta = [
      transaction.formattedDate,
      transaction.status ?? 'Berhasil',
      if (transaction.referenceNumber != null &&
          transaction.referenceNumber!.trim().isNotEmpty)
        transaction.referenceNumber!,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$amountPrefix${formatRupiah(transaction.amount.abs())}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: transaction.type.amountColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          transaction.type.label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          meta,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: BorderSide(color: borderColor ?? backgroundColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
