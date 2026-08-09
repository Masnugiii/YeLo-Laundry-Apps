import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/features/settings/models/system_settings_models.dart';

class SettingsRepository {
  SettingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CompanySettings> fetchCompanySettings() async {
    return _apiClient.get<CompanySettings>(
      '/settings/company',
      parser: (json) =>
          CompanySettings.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<CompanySettings> updateCompanySettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/settings/company',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return CompanySettings.fromJson(data);
  }

  Future<AttendanceSettingsConfig> fetchAttendanceSettings() async {
    return _apiClient.get<AttendanceSettingsConfig>(
      '/settings/attendance',
      parser: (json) =>
          AttendanceSettingsConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AttendanceSettingsConfig> updateAttendanceSettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/settings/attendance',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return AttendanceSettingsConfig.fromJson(data);
  }

  Future<DocumentRulesConfig> fetchDocumentRules() async {
    return _apiClient.get<DocumentRulesConfig>(
      '/settings/documents',
      parser: (json) =>
          DocumentRulesConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<DocumentRulesConfig> updateDocumentRules(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/settings/documents',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return DocumentRulesConfig.fromJson(data);
  }

  Future<NotificationSettingsConfig> fetchNotificationSettings() async {
    return _apiClient.get<NotificationSettingsConfig>(
      '/settings/notifications',
      parser: (json) =>
          NotificationSettingsConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<NotificationSettingsConfig> updateNotificationSettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/settings/notifications',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return NotificationSettingsConfig.fromJson(data);
  }

  Future<BackupSettingsConfig> fetchBackupSettings() async {
    return _apiClient.get<BackupSettingsConfig>(
      '/settings/backup',
      parser: (json) =>
          BackupSettingsConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BackupSettingsConfig> updateBackupSettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/settings/backup',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return BackupSettingsConfig.fromJson(data);
  }

  Future<DeliverySettingsConfig> fetchDeliverySettings() async {
    return _apiClient.get<DeliverySettingsConfig>(
      '/settings/delivery',
      parser: (json) =>
          DeliverySettingsConfig.fromJson(json as Map<String, dynamic>),
    );
  }
}
