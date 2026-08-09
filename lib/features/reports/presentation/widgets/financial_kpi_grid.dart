import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/report_theme.dart';

class FinancialKpiGrid extends StatelessWidget {
  const FinancialKpiGrid({
    super.key,
    required this.overview,
  });

  final FinancialOverview overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 520 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.s12,
          crossAxisSpacing: AppSpacing.s12,
          childAspectRatio: crossAxisCount == 4 ? 1.6 : 1.45,
          children: [
            _KpiCard(
              title: 'Omzet Kotor',
              value: formatRupiah(overview.grossRevenue),
            ),
            _KpiCard(
              title: 'Omzet Bersih',
              value: formatRupiah(overview.netRevenue),
            ),
            _KpiCard(
              title: 'Total Pengeluaran',
              value: formatRupiah(overview.totalExpenses),
            ),
            _KpiCard(
              title: 'Laba Bersih',
              value: formatRupiah(overview.netProfit),
              highlight: true,
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  final String title;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary : AppColors.surface,
        borderRadius: ReportTheme.cardRadius,
        boxShadow: AppShadows.md(),
        border: highlight
            ? null
            : Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: highlight
                  ? AppColors.onPrimary.withValues(alpha: 0.85)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.onPrimary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
