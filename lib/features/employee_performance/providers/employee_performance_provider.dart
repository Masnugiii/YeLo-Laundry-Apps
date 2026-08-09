import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';

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

EmployeeOverview _mapEmployeeOverview(
  Map<String, dynamic> json, {
  required int ranking,
}) {
  final productivity = (json['productivity'] as num?)?.toDouble() ?? 0;
  return EmployeeOverview(
    id: json['employeeId'] as String? ?? '',
    name: json['employeeName'] as String? ?? 'Unknown',
    role: _roleFromPosition(json['position'] as String?),
    currentPoints: (json['bonusEarned'] as num?)?.toInt() ?? 0,
    performanceScore: productivity.round(),
    level: _levelFromProductivity(productivity),
    ranking: ranking,
  );
}

PerformanceSummary _buildSummary(List<EmployeeOverview> employees) {
  return PerformanceSummary(
    totalEmployees: employees.length,
    excellent: employees
        .where((e) => e.level == PerformanceLevel.excellent)
        .length,
    good: employees.where((e) => e.level == PerformanceLevel.good).length,
    needImprovement: employees
        .where((e) => e.level == PerformanceLevel.needImprovement)
        .length,
  );
}

final employeePerformanceProvider =
    FutureProvider<({PerformanceSummary summary, List<EmployeeOverview> employees})>(
  (ref) async {
    final data = await ref.watch(apiClientProvider).get<Map<String, dynamic>>(
          '/reports/employees',
          queryParameters: {'period': 'this_month'},
          parser: (json) => json as Map<String, dynamic>,
        );

    final rawEmployees = (data['employees'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList()
      ..sort(
        (a, b) => ((b['productivity'] as num?) ?? 0)
            .compareTo((a['productivity'] as num?) ?? 0),
      );

    final employees = rawEmployees
        .asMap()
        .entries
        .map(
          (entry) => _mapEmployeeOverview(
            entry.value,
            ranking: entry.key + 1,
          ),
        )
        .toList();

    return (
      summary: _buildSummary(employees),
      employees: employees,
    );
  },
);

final employeePerformanceDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, employeeId) async {
  final data = await ref.watch(apiClientProvider).get<Map<String, dynamic>>(
        '/reports/employees',
        queryParameters: {
          'period': 'this_month',
          'employeeId': employeeId,
        },
        parser: (json) => json as Map<String, dynamic>,
      );

  final employees = data['employees'] as List<dynamic>? ?? const [];
  if (employees.isEmpty) {
    throw Exception('Data kinerja karyawan tidak ditemukan.');
  }

  return employees.first as Map<String, dynamic>;
});
