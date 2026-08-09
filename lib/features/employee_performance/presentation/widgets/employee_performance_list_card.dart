import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class EmployeePerformanceListCard extends StatelessWidget {
  const EmployeePerformanceListCard({
    super.key,
    required this.employee,
    required this.onTap,
  });

  final EmployeeOverview employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final levelColor = PerformanceTheme.levelColor(employee.level);

    return Material(
      color: AppColors.surface,
      borderRadius: PerformanceTheme.cardRadius,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: PerformanceTheme.cardRadius,
        child: Ink(
          decoration: PerformanceTheme.cardDecoration,
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      employee.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                employee.role.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _InfoRow(
                label: 'Current Point',
                value: '${employee.currentPoints}',
              ),
              const SizedBox(height: AppSpacing.s8),
              _InfoRow(
                label: 'Performance Score',
                value: '${employee.performanceScore}',
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Performance Level',
                      style: PerformanceTheme.labelStyle,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: levelColor),
                    ),
                    child: Text(
                      employee.level.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: levelColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              _InfoRow(
                label: 'Current Ranking',
                value: '#${employee.ranking}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
          child: Text(label, style: PerformanceTheme.labelStyle),
        ),
        Text(
          value,
          style: PerformanceTheme.valueStyle.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
