import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/data/dummy_employee_performance_data.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/ai_performance_insight_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/auto_calculation_note.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/auto_rating_info_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/employee_performance_list_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/monthly_leaderboard.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/performance_summary_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/point_rule_cards.dart';

class EmployeePerformanceScreen extends StatelessWidget {
  const EmployeePerformanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final employees = dummyEmployeeOverviews;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Kinerja Karyawan',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          const AutoRatingInfoCard(),
          const SizedBox(height: AppSpacing.s16),
          const PerformanceSummaryCard(summary: performanceSummary),
          const SizedBox(height: AppSpacing.s24),
          Text('Daftar Karyawan', style: PerformanceTheme.sectionTitleStyle),
          const SizedBox(height: AppSpacing.s12),
          for (var i = 0; i < employees.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            EmployeePerformanceListCard(
              employee: employees[i],
              onTap: () => context.push(
                '/employee-performance/${employees[i].id}',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s24),
          const PointRuleCards(rules: pointRules),
          const SizedBox(height: AppSpacing.s16),
          const MonthlyLeaderboard(entries: monthlyLeaderboard),
          const SizedBox(height: AppSpacing.s16),
          const AiPerformanceInsightCard(insights: aiPerformanceInsights),
          const SizedBox(height: AppSpacing.s16),
          const AutoCalculationNote(),
        ],
      ),
    );
  }
}
