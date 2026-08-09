import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';

class WalletTopUpSummaryCard extends StatelessWidget {
  const WalletTopUpSummaryCard({
    super.key,
    required this.confirmation,
  });

  final WalletTopUpConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Nama Pelanggan',
            value: confirmation.customerName,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Saldo Awal',
            value: formatRupiah(confirmation.initialBalance),
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Jumlah Top Up',
            value: formatRupiah(confirmation.topUpAmount),
            valueColor: const Color(0xFF22C55E),
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Saldo Akhir',
            value: formatRupiah(confirmation.finalBalance),
            valueColor: AppColors.primary,
            isBold: true,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Tanggal & Jam',
            value: '${confirmation.formattedDate}, ${confirmation.formattedTime}',
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Admin yang Bertanggung Jawab',
            value: confirmation.adminName,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Metode Pembayaran',
            value: confirmation.paymentMethodLabel,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}
