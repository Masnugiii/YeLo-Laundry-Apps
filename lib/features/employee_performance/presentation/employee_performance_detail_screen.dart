import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/data/dummy_employee_performance_data.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/activity_timeline.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/auto_calculation_note.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/employee_detail_header_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/point_rule_cards.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/system_kpi_section.dart';

class EmployeePerformanceDetailScreen extends StatelessWidget {
  const EmployeePerformanceDetailScreen({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    final detail = findEmployeeDetail(employeeId);

    if (detail == null) {
      return Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: _buildAppBar('Detail Karyawan'),
        body: Center(
          child: Text(
            'Karyawan tidak ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: _buildAppBar('Detail Karyawan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          EmployeeDetailHeaderCard(
            employee: detail.overview,
            monthlyRanking: detail.monthlyRanking,
          ),
          const SizedBox(height: AppSpacing.s16),
          SystemKpiSection(role: detail.role),
          const SizedBox(height: AppSpacing.s16),
          const PointRuleCards(rules: pointRules),
          const SizedBox(height: AppSpacing.s16),
          ActivityTimeline(events: detail.timeline),
          const SizedBox(height: AppSpacing.s16),
          const AutoCalculationNote(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.onPrimary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
