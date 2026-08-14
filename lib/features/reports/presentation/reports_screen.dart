import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/report_theme.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/binatu_performance_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/employee_performance_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/financial_kpi_grid.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/payment_analytics_chart.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/report_period_filter_bar.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/revenue_trend_chart.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/top_customers_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/top_services_chart.dart';
import 'package:yelo_laundry_erp/features/reports/providers/reports_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriodFilter _selectedFilter = ReportPeriodFilter.thisMonth;

  void _onFilterSelected(ReportPeriodFilter filter) {
    if (filter == ReportPeriodFilter.customRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Custom Range akan tersedia pada versi berikutnya.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider(_selectedFilter));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Laporan Bisnis',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          ReportPeriodFilterBar(
            selectedFilter: _selectedFilter,
            onFilterSelected: _onFilterSelected,
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => const ApiLoadingView(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () =>
                    ref.invalidate(financialReportProvider(_selectedFilter)),
              ),
              data: (report) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(financialReportProvider(_selectedFilter));
                  await ref.read(financialReportProvider(_selectedFilter).future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s8,
                    AppSpacing.s20,
                    AppSpacing.s32,
                  ),
                  children: [
                    ReportTheme.sectionCard(
                      title: 'Financial Overview',
                      child: FinancialKpiGrid(overview: report.overview),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Revenue Trend',
                      subtitle: 'Perkembangan omzet dalam periode terpilih',
                      child: report.revenueTrend.isEmpty
                          ? const _EmptyReportHint(
                              message: 'Belum ada data tren untuk periode ini.',
                            )
                          : RevenueTrendChart(data: report.revenueTrend),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Binatu Performance',
                      child: BinatuPerformanceCard(
                        performance: report.binatuPerformance,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Employee Performance',
                      subtitle: 'Performa tim binatu bulan ini',
                      child: report.employeePerformance.isEmpty
                          ? const _EmptyReportHint(
                              message:
                                  'Belum ada data performa karyawan untuk periode ini.',
                            )
                          : EmployeePerformanceCard(
                              employees: report.employeePerformance,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Customer Review',
                      subtitle: 'Ulasan pelanggan terbaru',
                      child: const _EmptyReportHint(
                        message:
                            'Data ulasan pelanggan belum tersedia dari backend.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Busy Day Calendar',
                      subtitle: 'Identifikasi hari ramai dan sepi',
                      child: const _EmptyReportHint(
                        message:
                            'Kalender hari ramai belum tersedia dari backend.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    const _EmptyReportHint(
                      message:
                          'AI Planner belum tersedia dari backend.',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Top Services',
                      subtitle: 'Layanan paling banyak dipesan',
                      child: report.topServices.isEmpty
                          ? const _EmptyReportHint(
                              message: 'Belum ada data layanan untuk periode ini.',
                            )
                          : TopServicesChart(services: report.topServices),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Top Customers',
                      subtitle: 'Pelanggan dengan kontribusi tertinggi',
                      child: report.topCustomers.isEmpty
                          ? const _EmptyReportHint(
                              message:
                                  'Belum ada data pelanggan untuk periode ini.',
                            )
                          : TopCustomersCard(customers: report.topCustomers),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ReportTheme.sectionCard(
                      title: 'Payment Analytics',
                      subtitle: 'Distribusi metode pembayaran',
                      child: report.paymentAnalytics.isEmpty
                          ? const _EmptyReportHint(
                              message:
                                  'Belum ada pembayaran untuk periode ini.',
                            )
                          : PaymentAnalyticsChart(
                              analytics: report.paymentAnalytics,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportHint extends StatelessWidget {
  const _EmptyReportHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
