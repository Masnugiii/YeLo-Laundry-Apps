import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/data/dummy_report_data.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/report_theme.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/ai_planner_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/binatu_performance_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/busy_day_calendar.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/customer_review_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/employee_performance_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/financial_kpi_grid.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/payment_analytics_chart.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/report_period_filter_bar.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/revenue_trend_chart.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/top_customers_card.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/widgets/top_services_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
    }
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const FinancialKpiGrid(overview: dummyFinancialOverview),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Revenue Trend',
                  subtitle: 'Perkembangan omzet bulanan (dalam jutaan Rp)',
                  child: const RevenueTrendChart(data: dummyRevenueTrend),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Binatu Performance',
                  child: const BinatuPerformanceCard(
                    performance: dummyBinatuPerformance,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Employee Performance',
                  subtitle: 'Performa tim binatu bulan ini',
                  child: const EmployeePerformanceCard(
                    employees: dummyEmployeePerformance,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Customer Review',
                  subtitle: 'Ulasan pelanggan terbaru',
                  child: const CustomerReviewCard(reviews: dummyCustomerReviews),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Busy Day Calendar',
                  subtitle: 'Identifikasi hari ramai dan sepi',
                  child: BusyDayCalendar(entries: dummyBusyDaysAugust2026),
                ),
                const SizedBox(height: AppSpacing.s16),
                const AiPlannerCard(recommendations: dummyAiRecommendations),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Top Services',
                  subtitle: 'Layanan paling banyak dipesan',
                  child: const TopServicesChart(services: dummyTopServices),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Top Customers',
                  subtitle: 'Pelanggan dengan kontribusi tertinggi',
                  child: const TopCustomersCard(customers: dummyTopCustomers),
                ),
                const SizedBox(height: AppSpacing.s16),
                ReportTheme.sectionCard(
                  title: 'Payment Analytics',
                  subtitle: 'Distribusi metode pembayaran',
                  child: const PaymentAnalyticsChart(
                    analytics: dummyPaymentAnalytics,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
