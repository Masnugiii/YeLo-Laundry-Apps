import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/utils/binatu_monitoring_date_helper.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class ReportsRepository {
  ReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchProduction({
    required BinatuMonitoringDateFilter filter,
    DateTime? customDate,
    String? employeeId,
  }) async {
    final query = _buildQuery(
      filter: filter,
      customDate: customDate,
      employeeId: employeeId,
    );

    return _apiClient.get<Map<String, dynamic>>(
      '/reports/production',
      queryParameters: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> fetchEmployeePerformance({
    required BinatuMonitoringDateFilter filter,
    DateTime? customDate,
    String? employeeId,
  }) async {
    final query = _buildQuery(
      filter: filter,
      customDate: customDate,
      employeeId: employeeId,
    );

    return _apiClient.get<Map<String, dynamic>>(
      '/reports/employees',
      queryParameters: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> fetchProductionForReportPeriod(
    ReportPeriodFilter period,
  ) async {
    final query = _reportPeriodQuery(period);

    return _apiClient.get<Map<String, dynamic>>(
      '/reports/production',
      queryParameters: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> fetchEmployeesForReportPeriod(
    ReportPeriodFilter period,
  ) async {
    final query = _reportPeriodQuery(period);

    return _apiClient.get<Map<String, dynamic>>(
      '/reports/employees',
      queryParameters: query,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Map<String, String> _buildQuery({
    required BinatuMonitoringDateFilter filter,
    DateTime? customDate,
    String? employeeId,
  }) {
    final range = BinatuMonitoringDateHelper.resolveRange(
      filter: filter,
      customDate: customDate ?? DateTime.now(),
    );

    final period = switch (filter) {
      BinatuMonitoringDateFilter.today => 'today',
      BinatuMonitoringDateFilter.yesterday => 'yesterday',
      BinatuMonitoringDateFilter.thisWeek => 'last_7_days',
      BinatuMonitoringDateFilter.thisMonth => 'this_month',
      BinatuMonitoringDateFilter.custom => 'custom',
    };

    return {
      'period': period,
      if (filter == BinatuMonitoringDateFilter.custom) ...{
        'dateFrom': range.start.toIso8601String(),
        'dateTo': range.end.toIso8601String(),
      },
      'employeeId': ?employeeId,
    };
  }

  Map<String, String> _reportPeriodQuery(ReportPeriodFilter period) {
    return switch (period) {
      ReportPeriodFilter.today => {'period': 'today'},
      ReportPeriodFilter.thisWeek => {'period': 'last_7_days'},
      ReportPeriodFilter.thisMonth => {'period': 'this_month'},
      ReportPeriodFilter.thisYear => {'period': 'last_30_days'},
      ReportPeriodFilter.customRange => {'period': 'this_month'},
    };
  }
}

BinatuMonitoringSummary mapProductionToMonitoringSummary(
  Map<String, dynamic> data,
) {
  final employees = (data['productionPerEmployee'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();

  return BinatuMonitoringSummary(
    activeBinatu: employees.where((item) => (item['jobsCompleted'] as num? ?? 0) > 0).length,
    totalIroningOrders: employees.fold<int>(
      0,
      (sum, item) => sum + ((item['jobsCompleted'] as num?)?.toInt() ?? 0),
    ),
    totalKgIroned: (data['kgProcessed'] as num?)?.toDouble() ?? 0,
    ordersStillInProgress: (data['delayedOrders'] as num?)?.toInt() ?? 0,
  );
}

List<BinatuEmployeeMonitoring> mapProductionEmployees(
  Map<String, dynamic> data,
) {
  return (data['productionPerEmployee'] as List<dynamic>? ?? const [])
      .map((item) {
        final map = item as Map<String, dynamic>;
        final jobs = (map['jobsCompleted'] as num?)?.toInt() ?? 0;
        return BinatuEmployeeMonitoring(
          id: map['employeeId'] as String? ?? '',
          name: map['employeeName'] as String? ?? 'Unknown',
          isActive: jobs > 0,
          totalIroningOrders: jobs,
          totalKgIroned: 0,
        );
      })
      .toList();
}

BinatuPerformance mapProductionToBinatuPerformance(Map<String, dynamic> data) {
  final completedKg = (data['kgProcessed'] as num?)?.toInt() ?? 0;
  final targetKg = completedKg > 0 ? (completedKg * 1.25).round() : 100;
  final progress = targetKg > 0 ? ((completedKg / targetKg) * 100).round().clamp(0, 100) : 0;

  return BinatuPerformance(
    completedKg: completedKg,
    monthlyTargetKg: targetKg,
    progressPercent: progress,
  );
}

List<EmployeePerformance> mapEmployeePerformanceReport(
  Map<String, dynamic> data,
) {
  final employees = (data['employees'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .toList()
    ..sort(
      (a, b) => ((b['kgProcessed'] as num?) ?? 0)
          .compareTo((a['kgProcessed'] as num?) ?? 0),
    );

  return [
    for (var i = 0; i < employees.length; i++)
      EmployeePerformance(
        name: employees[i]['employeeName'] as String? ?? 'Unknown',
        completedKg: (employees[i]['kgProcessed'] as num?)?.toInt() ?? 0,
        rank: i + 1,
      ),
  ];
}
