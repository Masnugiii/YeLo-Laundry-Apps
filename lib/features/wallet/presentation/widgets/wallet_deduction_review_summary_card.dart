import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';

class WalletDeductionReviewSummaryCard extends StatelessWidget {
  const WalletDeductionReviewSummaryCard({
    super.key,
    required this.confirmation,
  });

  final WalletPaymentConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Customer Name',
            value: confirmation.customerName,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Current Wallet Balance',
            value: formatRupiah(confirmation.initialBalance),
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Deduction Amount',
            value: formatRupiah(confirmation.deductionAmount),
            emphasized: true,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Remaining Balance',
            value: formatRupiah(confirmation.finalBalance),
            emphasized: true,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Responsible Admin',
            value: confirmation.adminName,
          ),
        ],
      ),
    );
  }
}

class WalletDeductionSuccessSummaryCard extends StatelessWidget {
  const WalletDeductionSuccessSummaryCard({
    super.key,
    required this.confirmation,
  });

  final WalletPaymentConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    final transactionNumber = WalletDeductionReceipt.formatTransactionNumber(
      confirmation.dateTime,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Customer Name',
            value: confirmation.customerName,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Nominal Dipotong',
            value: formatRupiah(confirmation.deductionAmount),
            emphasized: true,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Saldo Sebelum',
            value: formatRupiah(confirmation.initialBalance),
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Saldo Sesudah',
            value: formatRupiah(confirmation.finalBalance),
            emphasized: true,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Transaction Number',
            value: transactionNumber,
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Date & Time',
            value:
                '${confirmation.formattedDate}, ${confirmation.formattedTime} WIB',
          ),
          const _SummaryDivider(),
          _SummaryRow(
            label: 'Responsible Admin',
            value: confirmation.adminName,
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
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

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
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
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
