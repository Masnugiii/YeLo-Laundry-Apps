import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class TopCustomersCard extends StatelessWidget {
  const TopCustomersCard({
    super.key,
    required this.customers,
  });

  final List<TopCustomer> customers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < customers.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(height: AppSpacing.s16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s16),
          ],
          _CustomerRow(customer: customers[i], rank: i + 1),
        ],
      ],
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.rank,
  });

  final TopCustomer customer;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '#$rank',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                customer.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        _Detail(label: 'Total Spending', value: formatRupiah(customer.totalSpending)),
        const SizedBox(height: AppSpacing.s8),
        _Detail(
          label: 'Total Orders',
          value: '${customer.totalOrders} Order',
        ),
        const SizedBox(height: AppSpacing.s8),
        _Detail(label: 'Point', value: '${customer.points} Point'),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
