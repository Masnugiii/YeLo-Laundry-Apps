import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';

final employeeListProvider = FutureProvider.family<List<Employee>, String>(
  (ref, search) async {
    final response = await ref
        .watch(employeeRepositoryProvider)
        .fetchEmployees(page: 1, limit: 100, search: search.isEmpty ? null : search);
    return response.items;
  },
);

final employeeDetailProvider = FutureProvider.family<Employee, String>(
  (ref, id) => ref.watch(employeeRepositoryProvider).fetchEmployee(id),
);

final employeeStatisticsProvider = FutureProvider<EmployeeSummary>((ref) async {
  final stats = await ref.watch(employeeRepositoryProvider).fetchStatistics();
  return EmployeeSummary(
    total: (stats['totalEmployees'] as num?)?.toInt() ?? 0,
    owner: 0,
    kasir: (stats['cashiers'] as num?)?.toInt() ?? 0,
    binatu: (stats['binatu'] as num?)?.toInt() ?? 0,
  );
});

final suggestedEmployeeCodeProvider = FutureProvider<String>((ref) async {
  return ref.watch(employeeRepositoryProvider).fetchSuggestedEmployeeCode();
});
