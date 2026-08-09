import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';

/// Signed-in employee context for the dashboard header.
///
/// Future integration: replace [dummyDashboardEmployee] with the authenticated
/// employee from Employee Master (`fullName`, `gender`, `role`).
class DashboardEmployee {
  const DashboardEmployee({
    required this.name,
    required this.gender,
    required this.role,
    this.positionLabel,
  });

  final String name;
  final EmployeeGender gender;
  final EmployeeRole role;
  final String? positionLabel;

  String get greetingTitle => switch (gender) {
        EmployeeGender.male => 'Pak $name',
        EmployeeGender.female => 'Ibu $name',
      };

  String get roleLabel => positionLabel ?? role.label;
}
