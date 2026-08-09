import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/widgets/new_order_section_card.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
  });

  final int subtotal;
  final int discount;
  final int tax;
  final int grandTotal;

  @override
  Widget build(BuildContext context) {
    return NewOrderSectionCard(
      title: 'Ringkasan Order',
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: formatRupiah(subtotal)),
          const SizedBox(height: AppSpacing.s12),
          _SummaryRow(label: 'Diskon', value: formatRupiah(discount)),
          const SizedBox(height: AppSpacing.s12),
          _SummaryRow(label: 'Pajak', value: formatRupiah(tax)),
          const Divider(height: AppSpacing.s24),
          _SummaryRow(
            label: 'Grand Total',
            value: formatRupiah(grandTotal),
            isTotal: true,
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
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
