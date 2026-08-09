import 'package:flutter/material.dart';

enum EmployeeRole {
  owner,
  manager,
  kasir,
  binatu,
}

extension EmployeeRoleX on EmployeeRole {
  String get label => switch (this) {
        EmployeeRole.owner => 'Owner',
        EmployeeRole.manager => 'Manager',
        EmployeeRole.kasir => 'Kasir',
        EmployeeRole.binatu => 'Binatu',
      };

  Color get badgeBackground => switch (this) {
        EmployeeRole.owner => const Color(0xFF033B8E),
        EmployeeRole.manager => const Color(0xFFF8D613),
        EmployeeRole.kasir => const Color(0xFF4CAF50),
        EmployeeRole.binatu => const Color(0xFF9C27B0),
      };

  Color get badgeTextColor => switch (this) {
        EmployeeRole.owner => Colors.white,
        EmployeeRole.manager => const Color(0xFF033B8E),
        EmployeeRole.kasir => Colors.white,
        EmployeeRole.binatu => Colors.white,
      };
}

enum EmployeeStatus {
  active,
  inactive,
}

extension EmployeeStatusX on EmployeeStatus {
  String get label => switch (this) {
        EmployeeStatus.active => 'Active',
        EmployeeStatus.inactive => 'Inactive',
      };
}

enum EmployeeGender {
  male,
  female,
}

extension EmployeeGenderX on EmployeeGender {
  String get label => switch (this) {
        EmployeeGender.male => 'Laki-laki',
        EmployeeGender.female => 'Perempuan',
      };
}

enum EmployeeFilter {
  all,
  owner,
  manager,
  kasir,
  binatu,
  inactive,
}

extension EmployeeFilterX on EmployeeFilter {
  String get label => switch (this) {
        EmployeeFilter.all => 'All',
        EmployeeFilter.owner => 'Owner',
        EmployeeFilter.manager => 'Manager',
        EmployeeFilter.kasir => 'Kasir',
        EmployeeFilter.binatu => 'Binatu',
        EmployeeFilter.inactive => 'Inactive',
      };
}

class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.initials,
    required this.role,
    required this.status,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.joinDate,
    required this.emergencyContact,
    required this.branch,
    required this.position,
    this.kpiScore,
    this.currentPoint,
    this.monthlyRanking,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String initials;
  final EmployeeRole role;
  final EmployeeStatus status;
  final String phone;
  final EmployeeGender gender;
  final DateTime dateOfBirth;
  final String address;
  final DateTime joinDate;
  final String emergencyContact;
  final String branch;
  final String position;
  final int? kpiScore;
  final int? currentPoint;
  final int? monthlyRanking;

  bool get isActive => status == EmployeeStatus.active;
}

class EmployeeSummary {
  const EmployeeSummary({
    required this.total,
    required this.owner,
    required this.kasir,
    required this.binatu,
  });

  final int total;
  final int owner;
  final int kasir;
  final int binatu;
}

EmployeeSummary computeEmployeeSummary(List<Employee> employees) {
  return EmployeeSummary(
    total: employees.length,
    owner: employees.where((e) => e.role == EmployeeRole.owner).length,
    kasir: employees.where((e) => e.role == EmployeeRole.kasir).length,
    binatu: employees.where((e) => e.role == EmployeeRole.binatu).length,
  );
}

List<Employee> filterEmployees({
  required List<Employee> employees,
  required String query,
  required EmployeeFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return employees.where((employee) {
    final matchesFilter = switch (filter) {
      EmployeeFilter.all => true,
      EmployeeFilter.inactive => employee.status == EmployeeStatus.inactive,
      EmployeeFilter.owner => employee.role == EmployeeRole.owner,
      EmployeeFilter.manager => employee.role == EmployeeRole.manager,
      EmployeeFilter.kasir => employee.role == EmployeeRole.kasir,
      EmployeeFilter.binatu => employee.role == EmployeeRole.binatu,
    };

    if (!matchesFilter) return false;
    if (normalizedQuery.isEmpty) return true;

    return employee.fullName.toLowerCase().contains(normalizedQuery) ||
        employee.phone.toLowerCase().contains(normalizedQuery) ||
        employee.role.label.toLowerCase().contains(normalizedQuery) ||
        employee.employeeCode.toLowerCase().contains(normalizedQuery);
  }).toList();
}

String formatEmployeeDate(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
