import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_transaction.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({
    super.key,
    required this.transaction,
    required this.showDivider,
  });

  final WalletTransaction transaction;
  final bool showDivider;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final amountPrefix = transaction.isCredit ? '+ ' : '- ';
    final amountText =
        '$amountPrefix${formatRupiah(transaction.amount.abs())}';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _cardRadius,
            boxShadow: AppShadows.md(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s12),
              _Field(
                label: 'Jenis Transaksi',
                value: transaction.type.label,
                valueColor: transaction.type.amountColor,
              ),
              const SizedBox(height: AppSpacing.s12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s12),
              _Field(
                label: 'Nominal',
                value: amountText,
                valueColor: transaction.type.amountColor,
              ),
              const SizedBox(height: AppSpacing.s12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s12),
              _Field(
                label: 'Saldo Setelah Transaksi',
                value: formatRupiah(transaction.balanceAfter),
              ),
              if (transaction.referenceNumber != null &&
                  transaction.referenceNumber!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.s12),
                _Field(
                  label: 'Reference',
                  value: transaction.referenceNumber!,
                ),
              ],
              if (transaction.status != null) ...[
                const SizedBox(height: AppSpacing.s12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.s12),
                _Field(
                  label: 'Status',
                  value: transaction.status!,
                ),
              ],
              if (transaction.note != null) ...[
                const SizedBox(height: AppSpacing.s12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.s12),
                _Field(
                  label: 'Catatan',
                  value: transaction.note!,
                ),
              ],
            ],
          ),
        ),
        if (showDivider) const SizedBox(height: AppSpacing.s12),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
