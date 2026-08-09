import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class EmployeeDetailHeaderCard extends StatelessWidget {
  const EmployeeDetailHeaderCard({
    super.key,
    required this.employee,
    required this.monthlyRanking,
  });

  final EmployeeOverview employee;
  final int monthlyRanking;

  @override
  Widget build(BuildContext context) {
    final levelColor = PerformanceTheme.levelColor(employee.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: PerformanceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            employee.role.label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          _DetailRow(
            label: 'Performance Score',
            value: '${employee.performanceScore}',
          ),
          const SizedBox(height: AppSpacing.s12),
          _DetailRow(
            label: 'Current Point',
            value: '${employee.currentPoints}',
          ),
          const SizedBox(height: AppSpacing.s12),
          _DetailRow(
            label: 'Monthly Ranking',
            value: '#$monthlyRanking',
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Performance Level',
                  style: PerformanceTheme.labelStyle.copyWith(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: levelColor),
                ),
                child: Text(
                  employee.level.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
            style: PerformanceTheme.labelStyle.copyWith(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
