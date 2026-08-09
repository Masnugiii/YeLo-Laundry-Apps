import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class EmployeePerformanceCard extends StatelessWidget {
  const EmployeePerformanceCard({
    super.key,
    required this.employees,
  });

  final List<EmployeePerformance> employees;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < employees.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s12),
          _EmployeeRow(employee: employees[i]),
        ],
      ],
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.employee});

  final EmployeePerformance employee;

  @override
  Widget build(BuildContext context) {
    final isTop = employee.rank == 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: isTop
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(14),
        border: isTop
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop ? AppColors.primary : AppColors.divider,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${employee.rank}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isTop ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              employee.name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${employee.completedKg} Kg',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
