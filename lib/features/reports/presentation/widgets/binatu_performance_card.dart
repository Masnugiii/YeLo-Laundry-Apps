import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class BinatuPerformanceCard extends StatelessWidget {
  const BinatuPerformanceCard({
    super.key,
    required this.performance,
  });

  final BinatuPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow(
          label: 'Total Laundry Selesai',
          value: '${performance.completedKg} Kg',
        ),
        const SizedBox(height: AppSpacing.s12),
        _StatRow(
          label: 'Target Bulanan',
          value: '${performance.monthlyTargetKg} Kg',
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          'Progress',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: performance.progressPercent / 100,
            minHeight: 12,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${performance.progressPercent}%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
