import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/utils/binatu_monitoring_date_helper.dart';

List<BinatuEmployeeMonitoring> baseBinatuEmployees() {
  return const [
    BinatuEmployeeMonitoring(
      id: 'binatu-emp-001',
      name: 'Pak Budi',
      isActive: false,
      totalIroningOrders: 0,
      totalKgIroned: 0,
    ),
    BinatuEmployeeMonitoring(
      id: 'binatu-emp-002',
      name: 'Ibu Sari',
      isActive: false,
      totalIroningOrders: 0,
      totalKgIroned: 0,
    ),
    BinatuEmployeeMonitoring(
      id: 'binatu-emp-003',
      name: 'Pak Andi',
      isActive: false,
      totalIroningOrders: 0,
      totalKgIroned: 0,
    ),
    BinatuEmployeeMonitoring(
      id: 'binatu-emp-004',
      name: 'Ibu Dewi',
      isActive: false,
      totalIroningOrders: 0,
      totalKgIroned: 0,
    ),
  ];
}

List<BinatuMonitoringOrder> dummyBinatuMonitoringOrders() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    _order(
      id: 'bm-001',
      employeeId: 'binatu-emp-001',
      orderNumber: 'YL-004291',
      customerName: 'Andi Saputra',
      service: 'Cuci Kering Setrika',
      weightKg: 4.5,
      status: 'Finished Ironing',
      workDate: today,
      acceptedHour: 8,
      acceptedMinute: 15,
      finishedHour: 10,
      finishedMinute: 5,
    ),
    _order(
      id: 'bm-002',
      employeeId: 'binatu-emp-001',
      orderNumber: 'YL-004290',
      customerName: 'Siti Rahayu',
      service: 'Setrika Saja',
      weightKg: 3.0,
      status: 'Currently Ironing',
      workDate: today,
      acceptedHour: 9,
      acceptedMinute: 20,
    ),
    _order(
      id: 'bm-003',
      employeeId: 'binatu-emp-001',
      orderNumber: 'YL-004288',
      customerName: 'Dewi Lestari',
      service: 'Cuci Kering Setrika',
      weightKg: 6.0,
      status: 'Finished Ironing',
      workDate: today,
      acceptedHour: 7,
      acceptedMinute: 45,
      finishedHour: 9,
      finishedMinute: 30,
    ),
    _order(
      id: 'bm-004',
      employeeId: 'binatu-emp-002',
      orderNumber: 'YL-004287',
      customerName: 'Rina Wijaya',
      service: 'Setrika Saja',
      weightKg: 2.8,
      status: 'Finished Ironing',
      workDate: today,
      acceptedHour: 8,
      acceptedMinute: 5,
      finishedHour: 9,
      finishedMinute: 50,
    ),
    _order(
      id: 'bm-005',
      employeeId: 'binatu-emp-002',
      orderNumber: 'YL-004286',
      customerName: 'John Anderson',
      service: 'Cuci Kering Setrika',
      weightKg: 7.5,
      status: 'Accepted by Binatu',
      workDate: today,
      acceptedHour: 10,
      acceptedMinute: 10,
    ),
    _order(
      id: 'bm-006',
      employeeId: 'binatu-emp-003',
      orderNumber: 'YL-004280',
      customerName: 'Bambang Wijaya',
      service: 'Express Setrika',
      weightKg: 5.0,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 1)),
      acceptedHour: 9,
      acceptedMinute: 0,
      finishedHour: 11,
      finishedMinute: 15,
    ),
    _order(
      id: 'bm-007',
      employeeId: 'binatu-emp-004',
      orderNumber: 'YL-004279',
      customerName: 'Maya Putri',
      service: 'Setrika Saja',
      weightKg: 3.8,
      status: 'Finished Ironing',
      workDate: today,
      acceptedHour: 8,
      acceptedMinute: 30,
      finishedHour: 10,
      finishedMinute: 20,
    ),
    _order(
      id: 'bm-008',
      employeeId: 'binatu-emp-004',
      orderNumber: 'YL-004278',
      customerName: 'Hendra Gunawan',
      service: 'Cuci Kering Setrika',
      weightKg: 4.2,
      status: 'Currently Ironing',
      workDate: today,
      acceptedHour: 11,
      acceptedMinute: 5,
    ),
    _order(
      id: 'bm-009',
      employeeId: 'binatu-emp-001',
      orderNumber: 'YL-004275',
      customerName: 'Rudi Hartono',
      service: 'Setrika Saja',
      weightKg: 3.2,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 2)),
      acceptedHour: 10,
      acceptedMinute: 0,
      finishedHour: 11,
      finishedMinute: 30,
    ),
    _order(
      id: 'bm-010',
      employeeId: 'binatu-emp-002',
      orderNumber: 'YL-004274',
      customerName: 'Lina Marlina',
      service: 'Cuci Kering Setrika',
      weightKg: 5.5,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 3)),
      acceptedHour: 9,
      acceptedMinute: 15,
      finishedHour: 10,
      finishedMinute: 45,
    ),
    _order(
      id: 'bm-011',
      employeeId: 'binatu-emp-003',
      orderNumber: 'YL-004273',
      customerName: 'Agus Pratama',
      service: 'Express Setrika',
      weightKg: 4.0,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 4)),
      acceptedHour: 8,
      acceptedMinute: 30,
      finishedHour: 10,
      finishedMinute: 0,
    ),
    _order(
      id: 'bm-012',
      employeeId: 'binatu-emp-004',
      orderNumber: 'YL-004272',
      customerName: 'Fitri Handayani',
      service: 'Setrika Saja',
      weightKg: 2.5,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 5)),
      acceptedHour: 13,
      acceptedMinute: 0,
      finishedHour: 14,
      finishedMinute: 20,
    ),
    _order(
      id: 'bm-013',
      employeeId: 'binatu-emp-001',
      orderNumber: 'YL-004260',
      customerName: 'Eko Wibowo',
      service: 'Cuci Kering Setrika',
      weightKg: 6.8,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 7)),
      acceptedHour: 9,
      acceptedMinute: 0,
      finishedHour: 11,
      finishedMinute: 0,
    ),
    _order(
      id: 'bm-014',
      employeeId: 'binatu-emp-002',
      orderNumber: 'YL-004259',
      customerName: 'Sri Mulyani',
      service: 'Setrika Saja',
      weightKg: 3.6,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 10)),
      acceptedHour: 10,
      acceptedMinute: 30,
      finishedHour: 12,
      finishedMinute: 0,
    ),
    _order(
      id: 'bm-015',
      employeeId: 'binatu-emp-003',
      orderNumber: 'YL-004258',
      customerName: 'Doni Kusuma',
      service: 'Express Setrika',
      weightKg: 4.8,
      status: 'Finished Ironing',
      workDate: today.subtract(const Duration(days: 12)),
      acceptedHour: 8,
      acceptedMinute: 45,
      finishedHour: 10,
      finishedMinute: 15,
    ),
  ];
}

BinatuMonitoringOrder _order({
  required String id,
  required String employeeId,
  required String orderNumber,
  required String customerName,
  required String service,
  required double weightKg,
  required String status,
  required DateTime workDate,
  required int acceptedHour,
  required int acceptedMinute,
  int? finishedHour,
  int? finishedMinute,
}) {
  final acceptedAt = workDate.add(
    Duration(hours: acceptedHour, minutes: acceptedMinute),
  );
  final finishedAt = finishedHour == null
      ? null
      : workDate.add(Duration(hours: finishedHour, minutes: finishedMinute ?? 0));

  return BinatuMonitoringOrder(
    id: id,
    employeeId: employeeId,
    orderNumber: orderNumber,
    customerName: customerName,
    laundryService: service,
    weightKg: weightKg,
    status: status,
    workDate: workDate,
    acceptedAt: acceptedAt,
    finishedAt: finishedAt,
  );
}

List<BinatuMonitoringOrder> ordersForDateRange(BinatuMonitoringDateRange range) {
  return dummyBinatuMonitoringOrders()
      .where((order) => range.contains(order.workDate))
      .toList();
}

List<BinatuMonitoringOrder> dummyBinatuMonitoringOrdersForDate(DateTime date) {
  final normalized = BinatuMonitoringDateHelper.normalize(date);
  return ordersForDateRange(
    BinatuMonitoringDateRange(start: normalized, end: normalized),
  );
}

List<BinatuMonitoringOrder> ordersForEmployeeInRange(
  String employeeId,
  BinatuMonitoringDateRange range,
) {
  return ordersForDateRange(range)
      .where((order) => order.employeeId == employeeId)
      .toList();
}

List<BinatuMonitoringOrder> ordersForEmployeeOnDate(
  String employeeId,
  DateTime date,
) {
  return ordersForEmployeeInRange(
    employeeId,
    BinatuMonitoringDateRange(
      start: BinatuMonitoringDateHelper.normalize(date),
      end: BinatuMonitoringDateHelper.normalize(date),
    ),
  );
}

List<BinatuEmployeeMonitoring> employeesForDateRange(
  BinatuMonitoringDateRange range,
) {
  final orders = ordersForDateRange(range);

  return baseBinatuEmployees().map((employee) {
    final employeeOrders = orders
        .where((order) => order.employeeId == employee.id)
        .toList();

    return BinatuEmployeeMonitoring(
      id: employee.id,
      name: employee.name,
      isActive: employeeOrders.isNotEmpty,
      totalIroningOrders: employeeOrders.length,
      totalKgIroned: employeeOrders.fold<double>(
        0,
        (sum, order) => sum + order.weightKg,
      ),
    );
  }).toList();
}

BinatuMonitoringSummary monitoringSummaryForRange(
  BinatuMonitoringDateRange range,
) {
  final orders = ordersForDateRange(range);
  final activeEmployeeIds = orders.map((order) => order.employeeId).toSet();

  return BinatuMonitoringSummary(
    activeBinatu: activeEmployeeIds.length,
    totalIroningOrders: orders.length,
    totalKgIroned: orders.fold<double>(0, (sum, order) => sum + order.weightKg),
    ordersStillInProgress: orders
        .where(
          (order) =>
              order.status == 'Currently Ironing' ||
              order.status == 'Accepted by Binatu',
        )
        .length,
  );
}

BinatuEmployeeMonitoring? employeeMonitoringById(String id) {
  for (final employee in baseBinatuEmployees()) {
    if (employee.id == id) return employee;
  }
  return null;
}

EmployeeDailyMonitoringStats employeeStatsForRange(
  String employeeId,
  BinatuMonitoringDateRange range,
) {
  final orders = ordersForEmployeeInRange(employeeId, range);
  return EmployeeDailyMonitoringStats(
    totalIroningOrders: orders.length,
    totalKgIroned: orders.fold<double>(0, (sum, order) => sum + order.weightKg),
  );
}

EmployeeDailyMonitoringStats employeeStatsForDate(
  String employeeId,
  DateTime date,
) {
  final normalized = BinatuMonitoringDateHelper.normalize(date);
  return employeeStatsForRange(
    employeeId,
    BinatuMonitoringDateRange(start: normalized, end: normalized),
  );
}

class EmployeeDailyMonitoringStats {
  const EmployeeDailyMonitoringStats({
    required this.totalIroningOrders,
    required this.totalKgIroned,
  });

  final int totalIroningOrders;
  final double totalKgIroned;
}
