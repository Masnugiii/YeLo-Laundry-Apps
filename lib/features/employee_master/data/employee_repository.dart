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

  Future<Map<String, dynamic>> fetchStatistics() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/employees/statistics',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<String> fetchSuggestedEmployeeCode() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/numbering/EMP',
      parser: (json) => json as Map<String, dynamic>,
    );

    final prefix = data['prefix'] as String? ?? 'EMP';
    final padding = (data['padding'] as num?)?.toInt() ?? 4;
    final counter = (data['currentCounter'] as num?)?.toInt() ?? 0;
    final dailyReset = data['dailyReset'] as bool? ?? false;
    final next = counter + 1;
    final padded = next.toString().padLeft(padding, '0');

    if (dailyReset) {
      final now = DateTime.now();
      final datePart =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      return '$prefix-$datePart-$padded';
    }

    return '$prefix-$padded';
  }

  Future<Employee> createEmployee({
    required String employeeCode,
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? position,
    String status = 'ACTIVE',
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/employees',
      data: {
        'employeeCode': employeeCode,
        'fullName': fullName,
        'phone': phone,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
        if (position != null && position.isNotEmpty) 'position': position,
        'status': status,
      },
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
      status: (json['status'] as String? ?? '').toUpperCase() == 'ACTIVE'
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
    if (roles.contains('DRIVER')) return EmployeeRole.kasir;
    if (roles.contains('OPERATOR')) return EmployeeRole.kasir;
    return EmployeeRole.kasir;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
