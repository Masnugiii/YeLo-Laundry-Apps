import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart'
    as master;
import 'package:yelo_laundry_erp/features/settings/models/reminder_recipient_employee.dart';

ReminderRecipientEmployee _mapEmployee(master.Employee employee) {
  final role = employee.role == master.EmployeeRole.manager
      ? ReminderRecipientRole.manager
      : ReminderRecipientRole.owner;

  return ReminderRecipientEmployee(
    id: employee.id,
    name: employee.fullName,
    role: role,
    whatsapp: employee.phone,
    initials: employee.initials,
  );
}

final reminderRecipientEmployeesProvider =
    FutureProvider<List<ReminderRecipientEmployee>>((ref) async {
  final response = await ref.read(employeeRepositoryProvider).fetchEmployees(
        page: 1,
        limit: 100,
      );

  return response.items
      .where(
        (employee) =>
            employee.isActive &&
            (employee.role == master.EmployeeRole.owner ||
                employee.role == master.EmployeeRole.manager),
      )
      .map(_mapEmployee)
      .toList();
});
