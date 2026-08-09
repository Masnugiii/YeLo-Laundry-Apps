import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/performance_theme.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/employee_performance_list_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/widgets/performance_summary_card.dart';
import 'package:yelo_laundry_erp/features/employee_performance/providers/employee_performance_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class EmployeePerformanceScreen extends ConsumerWidget {
  const EmployeePerformanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(employeePerformanceProvider);

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
      body: performanceAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(employeePerformanceProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(employeePerformanceProvider);
            await ref.read(employeePerformanceProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            children: [
              PerformanceSummaryCard(summary: data.summary),
              const SizedBox(height: AppSpacing.s24),
              Text('Daftar Karyawan', style: PerformanceTheme.sectionTitleStyle),
              const SizedBox(height: AppSpacing.s12),
              if (data.employees.isEmpty)
                Text(
                  'Belum ada data kinerja untuk periode ini.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                for (var i = 0; i < data.employees.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  EmployeePerformanceListCard(
                    employee: data.employees[i],
                    onTap: () => context.push(
                      '/employee-performance/${data.employees[i].id}',
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
