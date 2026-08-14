import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/role/role_mapper.dart';
import 'package:yelo_laundry_erp/core/session/app_user_session.dart';
import 'package:yelo_laundry_erp/core/storage/preferences_service.dart';
import 'package:yelo_laundry_erp/core/storage/secure_storage_service.dart';

class AuthRepository {
  AuthRepository({
    required this._apiClient,
    required this._secureStorage,
    required this._preferences,
  });

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final PreferencesService? _preferences;

  Future<AppUserSession> login({
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'phone': phone,
        'password': password,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final accessToken = data['accessToken'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final roles = (user['roles'] as List<dynamic>).map((e) => e.toString()).toList();
    final permissions = (user['permissions'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    await _secureStorage.saveAccessToken(accessToken);

    final session = AppUserSession(
      id: user['id'] as String,
      employeeCode: user['employeeCode'] as String,
      name: user['fullName'] as String,
      phone: user['phone'] as String,
      roles: roles,
      permissions: permissions,
      role: mapBackendRoleToUserRole(roles),
      isAuthenticated: true,
    );

    await _preferences?.saveProfile(session);
    return session;
  }

  Future<AppUserSession> fetchProfile() async {
    final user = await _apiClient.get<Map<String, dynamic>>(
      '/auth/profile',
      parser: (json) => json as Map<String, dynamic>,
    );

    final roles = (user['roles'] as List<dynamic>).map((e) => e.toString()).toList();
    final permissions = (user['permissions'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    final session = AppUserSession(
      id: user['id'] as String,
      employeeCode: user['employeeCode'] as String,
      name: user['fullName'] as String,
      phone: user['phone'] as String,
      roles: roles,
      permissions: permissions,
      role: mapBackendRoleToUserRole(roles),
      isAuthenticated: true,
    );

    await _preferences?.saveProfile(session);
    return session;
  }

  Future<AppUserSession?> restoreSession() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await fetchProfile();
    } catch (_) {
      final cached = _preferences?.readProfile();
      if (cached != null) {
        return cached.copyWith(isAuthenticated: true);
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>('/auth/logout');
    } catch (_) {
      // Ignore logout API errors and clear local session anyway.
    }

    await _secureStorage.clearTokens();
    await _preferences?.clearProfile();
  }
}
