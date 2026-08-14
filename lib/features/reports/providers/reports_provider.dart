import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/reports/data/reports_repository.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class FinancialReportData {
  const FinancialReportData({
    required this.overview,
    required this.revenueTrend,
    required this.paymentAnalytics,
    required this.topServices,
    required this.topCustomers,
    required this.binatuPerformance,
    required this.employeePerformance,
  });

  final FinancialOverview overview;
  final List<RevenueTrendPoint> revenueTrend;
  final List<PaymentAnalytic> paymentAnalytics;
  final List<TopService> topServices;
  final List<TopCustomer> topCustomers;
  final BinatuPerformance binatuPerformance;
  final List<EmployeePerformance> employeePerformance;
}

String reportPeriodToApi(ReportPeriodFilter filter) {
  return switch (filter) {
    ReportPeriodFilter.today => 'daily',
    ReportPeriodFilter.thisWeek => 'weekly',
    ReportPeriodFilter.thisMonth => 'monthly',
    ReportPeriodFilter.thisYear => 'yearly',
    ReportPeriodFilter.customRange => 'monthly',
  };
}

FinancialReportData mapFinancialReportData({
  required Map<String, dynamic> summary,
  required Map<String, dynamic> dashboard,
  required Map<String, dynamic> production,
  required Map<String, dynamic> employees,
}) {
  final profitLoss =
      summary['profitLoss'] as Map<String, dynamic>? ?? const {};
  final expense = summary['expense'] as Map<String, dynamic>? ?? const {};
  final payment = summary['payment'] as Map<String, dynamic>? ?? const {};
  final trend = summary['trend'] as List<dynamic>? ?? const [];

  final revenue = (profitLoss['revenue'] as num?)?.toInt() ?? 0;
  final refunds = (profitLoss['refunds'] as num?)?.toInt() ?? 0;
  final netProfit = (profitLoss['netProfit'] as num?)?.toInt() ?? 0;

  final paymentBuckets = <({String label, num amount, Color color})>[
    (label: 'Cash', amount: payment['cash'] as num? ?? 0, color: AppColors.primary),
    (label: 'QRIS', amount: payment['qris'] as num? ?? 0, color: AppColors.accent),
    (
      label: 'Transfer',
      amount: payment['transfer'] as num? ?? 0,
      color: const Color(0xFF2563EB),
    ),
    (
      label: 'Wallet',
      amount: payment['wallet'] as num? ?? 0,
      color: const Color(0xFF16A34A),
    ),
  ];
  final paymentTotal = paymentBuckets.fold<num>(
    0,
    (sum, item) => sum + item.amount,
  );

  final topServices = (dashboard['topServices'] as List<dynamic>? ?? const [])
      .map(
        (item) => TopService(
          name: (item as Map<String, dynamic>)['serviceName'] as String? ??
              'Unknown',
          orderCount: (item['orderCount'] as num?)?.toInt() ?? 0,
        ),
      )
      .toList();

  final topCustomers =
      (dashboard['topCustomers'] as List<dynamic>? ?? const [])
          .map(
            (item) => TopCustomer(
              name: (item as Map<String, dynamic>)['customerName'] as String? ??
                  'Unknown',
              totalSpending: (item['revenue'] as num?)?.toInt() ?? 0,
              totalOrders: (item['orderCount'] as num?)?.toInt() ?? 0,
              points: 0,
            ),
          )
          .toList();

  return FinancialReportData(
    overview: FinancialOverview(
      grossRevenue: revenue,
      netRevenue: revenue - refunds,
      totalExpenses: (expense['total'] as num?)?.toInt() ?? 0,
      netProfit: netProfit,
    ),
    revenueTrend: trend
        .map(
          (item) => RevenueTrendPoint(
            month: (item as Map<String, dynamic>)['label'] as String? ?? '',
            grossRevenue: ((item['revenue'] as num?) ?? 0).toDouble(),
            netRevenue: ((item['netProfit'] as num?) ?? 0).toDouble(),
          ),
        )
        .toList(),
    paymentAnalytics: paymentBuckets
        .where((item) => item.amount > 0)
        .map(
          (item) => PaymentAnalytic(
            method: item.label,
            percentage: paymentTotal > 0
                ? (item.amount / paymentTotal) * 100
                : 0,
            color: item.color,
          ),
        )
        .toList(),
    topServices: topServices,
    topCustomers: topCustomers,
    binatuPerformance: mapProductionToBinatuPerformance(production),
    employeePerformance: mapEmployeePerformanceReport(employees),
  );
}

final financialReportProvider =
    FutureProvider.family<FinancialReportData, ReportPeriodFilter>(
  (ref, period) async {
    final repository = ref.watch(financeRepositoryProvider);
    final reportsRepository = ref.watch(reportsRepositoryProvider);
    final apiPeriod = reportPeriodToApi(period);

    final results = await Future.wait([
      repository.fetchFinancialSummary(period: apiPeriod),
      repository.fetchDashboard(),
      reportsRepository.fetchProductionForReportPeriod(period),
      reportsRepository.fetchEmployeesForReportPeriod(period),
    ]);

    return mapFinancialReportData(
      summary: results[0],
      dashboard: results[1],
      production: results[2],
      employees: results[3],
    );
  },
);

final todayPaymentsProvider = FutureProvider((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final response = await repository.fetchPayments(
    page: 1,
    limit: 50,
    dateFrom: start,
    dateTo: end,
  );

  return response.items;
});

final todayPaymentHistoryProvider = FutureProvider((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return repository.fetchPaymentHistory(period: 'daily');
});
