import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';

class PointRuleCards extends StatelessWidget {
  const PointRuleCards({
    super.key,
    required this.rules,
  });

  final List<PointRule> rules;

  @override
  Widget build(BuildContext context) {
    return PerformanceTheme.sectionCard(
      title: 'Point Rule',
      subtitle: 'Aturan poin otomatis berdasarkan aktivitas sistem.',
      child: Column(
        children: [
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            _PointRuleCard(rule: rules[i]),
          ],
        ],
      ),
    );
  }
}

class _PointRuleCard extends StatelessWidget {
  const _PointRuleCard({required this.rule});

  final PointRule rule;

  @override
  Widget build(BuildContext context) {
    final isNegative = rule.points < 0;
    final pointColor = isNegative ? AppColors.error : AppColors.success;
    final pointText =
        isNegative ? '${rule.points} Point' : '+${rule.points} Point';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  rule.condition,
                  style: PerformanceTheme.labelStyle,
                ),
              ],
            ),
          ),
          Text(
            pointText,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: pointColor,
            ),
          ),
        ],
      ),
    );
  }
}
