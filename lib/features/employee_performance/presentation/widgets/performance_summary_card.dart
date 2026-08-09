import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class PerformanceSummaryCard extends StatelessWidget {
  const PerformanceSummaryCard({
    super.key,
    required this.summary,
  });

  final PerformanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: PerformanceTheme.cardDecoration,
      child: Column(
        children: [
          _SummaryRow(
            label: 'Total Karyawan',
            value: '${summary.totalEmployees}',
            valueColor: AppColors.primary,
          ),
          const _Divider(),
          _SummaryRow(
            label: 'Excellent',
            value: '${summary.excellent}',
            valueColor: AppColors.success,
          ),
          const _Divider(),
          _SummaryRow(
            label: 'Good',
            value: '${summary.good}',
            valueColor: AppColors.primary,
          ),
          const _Divider(),
          _SummaryRow(
            label: 'Need Improvement',
            value: '${summary.needImprovement}',
            valueColor: AppColors.warning,
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
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PerformanceTheme.labelStyle.copyWith(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}
