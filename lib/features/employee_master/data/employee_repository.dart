import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';

class EmployeeRepository {
  EmployeeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedResponse<Employee>> fetchEmployees({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/employees',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapEmployee(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<Employee> fetchEmployee(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/employees/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapEmployee(data);
  }

  Employee _mapEmployee(Map<String, dynamic> json) {
    final fullName = json['fullName'] as String? ?? '';
    final roles = (json['roles'] as List<dynamic>? ?? const [])
        .map((role) => role.toString())
        .toList();

    return Employee(
      id: json['id'] as String,
      employeeCode: json['employeeCode'] as String? ?? '',
      fullName: fullName,
      initials: _initials(fullName),
      role: _mapRole(roles),
      status: json['status'] == 'active'
          ? EmployeeStatus.active
          : EmployeeStatus.inactive,
      phone: json['phone'] as String? ?? '',
      gender: EmployeeGender.male,
      dateOfBirth: DateTime(1990, 1, 1),
      address: json['address'] as String? ?? '-',
      joinDate: DateTime.tryParse(json['hiredAt'] as String? ?? '') ??
          DateTime.now(),
      emergencyContact: '-',
      branch: 'Main',
      position: json['position'] as String? ?? '',
    );
  }

  EmployeeRole _mapRole(List<String> roles) {
    if (roles.contains('OWNER')) return EmployeeRole.owner;
    if (roles.contains('MANAGER')) return EmployeeRole.manager;
    if (roles.contains('BINATU')) return EmployeeRole.binatu;
    return EmployeeRole.kasir;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
