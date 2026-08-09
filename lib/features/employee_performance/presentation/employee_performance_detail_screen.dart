import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/employee_api_kpi_section.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/employee_detail_header_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/providers/employee_performance_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class EmployeePerformanceDetailScreen extends ConsumerWidget {
  const EmployeePerformanceDetailScreen({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  PerformanceLevel _levelFromProductivity(num productivity) {
    if (productivity >= 80) return PerformanceLevel.excellent;
    if (productivity >= 60) return PerformanceLevel.good;
    return PerformanceLevel.needImprovement;
  }

  EmployeeRole _roleFromPosition(String? position) {
    final normalized = (position ?? '').toLowerCase();
    if (normalized.contains('binatu')) return EmployeeRole.binatu;
    return EmployeeRole.kasir;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(employeePerformanceDetailProvider(employeeId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Detail Karyawan',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () =>
              ref.invalidate(employeePerformanceDetailProvider(employeeId)),
        ),
        data: (metrics) {
          final productivity = (metrics['productivity'] as num?)?.toDouble() ?? 0;
          final overview = EmployeeOverview(
            id: metrics['employeeId'] as String? ?? employeeId,
            name: metrics['employeeName'] as String? ?? 'Unknown',
            role: _roleFromPosition(metrics['position'] as String?),
            currentPoints: (metrics['bonusEarned'] as num?)?.toInt() ?? 0,
            performanceScore: productivity.round(),
            level: _levelFromProductivity(productivity),
            ranking: 0,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            children: [
              EmployeeDetailHeaderCard(
                employee: overview,
                monthlyRanking: 0,
              ),
              const SizedBox(height: AppSpacing.s16),
              EmployeeApiKpiSection(metrics: metrics),
            ],
          );
        },
      ),
    );
  }
}
