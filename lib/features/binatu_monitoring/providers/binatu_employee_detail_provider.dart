import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/reports/data/reports_repository.dart';

class BinatuEmployeeDetailQuery {
  const BinatuEmployeeDetailQuery({
    required this.employeeId,
    required this.filter,
    this.customDate,
  });

  final String employeeId;
  final BinatuMonitoringDateFilter filter;
  final DateTime? customDate;

  @override
  bool operator ==(Object other) {
    return other is BinatuEmployeeDetailQuery &&
        other.employeeId == employeeId &&
        other.filter == filter &&
        other.customDate == customDate;
  }

  @override
  int get hashCode => Object.hash(employeeId, filter, customDate);
}

BinatuMonitoringOrder mapLaundryOrderToMonitoringOrder(
  Map<String, dynamic> json,
  String employeeId,
) {
  final receivedAt = DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
      DateTime.now();
  final stageStartedAt =
      DateTime.tryParse(json['stageStartedAt'] as String? ?? '') ?? receivedAt;

  return BinatuMonitoringOrder(
    id: json['orderId'] as String? ?? '',
    employeeId: employeeId,
    orderNumber: json['orderNumber'] as String? ?? '-',
    customerName: json['customerName'] as String? ?? '-',
    laundryService: json['serviceSummary'] as String? ?? '-',
    weightKg: (json['totalWeight'] as num?)?.toDouble() ?? 0,
    status: json['productionStatus'] as String? ?? json['orderStatus'] as String? ?? '-',
    workDate: receivedAt,
    acceptedAt: stageStartedAt,
    finishedAt: json['productionStatus'] == 'READY' ? DateTime.now() : null,
  );
}

final binatuEmployeeDetailProvider = FutureProvider.family<
    ({
      BinatuEmployeeMonitoring employee,
      BinatuMonitoringSummary stats,
      List<BinatuMonitoringOrder> orders,
    }),
    BinatuEmployeeDetailQuery>((ref, query) async {
  final reportsRepository = ref.watch(reportsRepositoryProvider);
  final production = await reportsRepository.fetchProduction(
    filter: query.filter,
    customDate: query.customDate,
    employeeId: query.employeeId,
  );

  final laundryOrders = await ref.read(laundryRepositoryProvider).fetchQueue(
        page: 1,
        limit: 50,
        employeeId: query.employeeId,
      );

  final employees = mapProductionEmployees(production);
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

  final jobs = (production['productionPerEmployee'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .where((item) => item['employeeId'] == query.employeeId)
      .fold<int>(
        0,
        (sum, item) => sum + ((item['jobsCompleted'] as num?)?.toInt() ?? 0),
      );

  final orders = laundryOrders.items
      .map((item) => mapLaundryOrderToMonitoringOrder(item, query.employeeId))
      .toList();

  return (
    employee: employee.copyWith(
      totalIroningOrders: jobs > 0 ? jobs : orders.length,
      totalKgIroned: orders.fold<double>(
        0,
        (sum, order) => sum + order.weightKg,
      ),
    ),
    stats: BinatuMonitoringSummary(
      activeBinatu: jobs > 0 || orders.isNotEmpty ? 1 : 0,
      totalIroningOrders: jobs > 0 ? jobs : orders.length,
      totalKgIroned: orders.fold<double>(
        0,
        (sum, order) => sum + order.weightKg,
      ),
      ordersStillInProgress: orders.length,
    ),
    orders: orders,
  );
});

extension on BinatuEmployeeMonitoring {
  BinatuEmployeeMonitoring copyWith({
    int? totalIroningOrders,
    double? totalKgIroned,
  }) {
    return BinatuEmployeeMonitoring(
      id: id,
      name: name,
      isActive: isActive,
      totalIroningOrders: totalIroningOrders ?? this.totalIroningOrders,
      totalKgIroned: totalKgIroned ?? this.totalKgIroned,
    );
  }
}
