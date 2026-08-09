import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';

class EmployeeSummaryGrid extends StatelessWidget {
  const EmployeeSummaryGrid({
    super.key,
    required this.summary,
  });

  final EmployeeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Employees',
                value: '${summary.total}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'Owner',
                value: '${summary.owner}',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Kasir',
                value: '${summary.kasir}',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'Binatu',
                value: '${summary.binatu}',
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: EmployeeMasterTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: EmployeeMasterTheme.labelStyle,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
