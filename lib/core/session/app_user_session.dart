import 'package:yelo_laundry_erp/core/role/role.dart';

class AppUserSession {
  const AppUserSession({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.phone,
    required this.role,
    required this.roles,
    this.isAuthenticated = false,
  });

  final String id;
  final String employeeCode;
  final String name;
  final String phone;
  final UserRole role;
  final List<String> roles;
  final bool isAuthenticated;

  AppUserSession copyWith({
    String? id,
    String? employeeCode,
    String? name,
    String? phone,
    UserRole? role,
    List<String>? roles,
    bool? isAuthenticated,
  }) {
    return AppUserSession(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'name': name,
      'phone': phone,
      'role': role.name,
      'roles': roles,
      'isAuthenticated': isAuthenticated,
    };
  }

  factory AppUserSession.fromJson(Map<String, dynamic> json) {
    return AppUserSession(
      id: json['id'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (value) => value.name == json['role'],
        orElse: () => UserRole.cashier,
      ),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
    );
  }

  static const guest = AppUserSession(
    id: '',
    employeeCode: '',
    name: '',
    phone: '',
    role: UserRole.cashier,
    roles: const [],
    isAuthenticated: false,
  );
}
