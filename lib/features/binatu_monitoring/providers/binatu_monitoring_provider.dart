import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/reports/data/reports_repository.dart';

class BinatuMonitoringQuery {
  const BinatuMonitoringQuery({
    required this.filter,
    this.customDate,
  });

  final BinatuMonitoringDateFilter filter;
  final DateTime? customDate;

  @override
  bool operator ==(Object other) {
    return other is BinatuMonitoringQuery &&
        other.filter == filter &&
        other.customDate == customDate;
  }

  @override
  int get hashCode => Object.hash(filter, customDate);
}

class BinatuMonitoringData {
  const BinatuMonitoringData({
    required this.summary,
    required this.employees,
  });

  final BinatuMonitoringSummary summary;
  final List<BinatuEmployeeMonitoring> employees;
}

final binatuMonitoringProvider =
    FutureProvider.family<BinatuMonitoringData, BinatuMonitoringQuery>(
  (ref, query) async {
    final repository = ref.watch(reportsRepositoryProvider);
    final data = await repository.fetchProduction(
      filter: query.filter,
      customDate: query.customDate,
    );

    return BinatuMonitoringData(
      summary: mapProductionToMonitoringSummary(data),
      employees: mapProductionEmployees(data),
    );
  },
);

final binatuEmployeeMonitoringProvider = FutureProvider.family<
    ({
      BinatuEmployeeMonitoring employee,
      BinatuMonitoringSummary stats,
    }),
    ({
      String employeeId,
      BinatuMonitoringDateFilter filter,
      DateTime? customDate,
    })>((ref, query) async {
  final repository = ref.watch(reportsRepositoryProvider);
  final data = await repository.fetchProduction(
    filter: query.filter,
    customDate: query.customDate,
    employeeId: query.employeeId,
  );

  final employees = mapProductionEmployees(data);
  final employee = employees.firstWhere(
    (item) => item.id == query.employeeId,
    orElse: () => BinatuEmployeeMonitoring(
      id: query.employeeId,
      name: 'Karyawan',
      isActive: false,
      totalIroningOrders: 0,
      totalKgIroned: 0,
    ),
  );

  final jobs = (data['productionPerEmployee'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .where((item) => item['employeeId'] == query.employeeId)
      .fold<int>(
        0,
        (sum, item) => sum + ((item['jobsCompleted'] as num?)?.toInt() ?? 0),
      );

  return (
    employee: employee,
    stats: BinatuMonitoringSummary(
      activeBinatu: jobs > 0 ? 1 : 0,
      totalIroningOrders: jobs,
      totalKgIroned: (data['kgProcessed'] as num?)?.toDouble() ?? 0,
      ordersStillInProgress: (data['delayedOrders'] as num?)?.toInt() ?? 0,
    ),
  );
});
