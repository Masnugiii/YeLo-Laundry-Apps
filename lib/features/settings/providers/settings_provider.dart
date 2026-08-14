import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_settings_config.dart';
import 'package:yelo_laundry_erp/features/settings/models/system_settings_models.dart';

final isOwnerSettingsProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider).roles.contains('OWNER');
});

final companySettingsProvider =
    FutureProvider.autoDispose<CompanySettings>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchCompanySettings();
});

final attendanceSettingsProvider =
    FutureProvider.autoDispose<AttendanceSettingsConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchAttendanceSettings();
});

final documentRulesProvider =
    FutureProvider.autoDispose<DocumentRulesConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchDocumentRules();
});

final notificationSettingsConfigProvider =
    FutureProvider.autoDispose<NotificationSettingsConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchNotificationSettings();
});

final backupSettingsProvider =
    FutureProvider.autoDispose<BackupSettingsConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchBackupSettings();
});

final deliverySettingsProvider =
    FutureProvider.autoDispose<DeliverySettingsConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchDeliverySettings();
});

final paymentConfigProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchSettingsSection('payment');
});

final numberingSettingsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchSettingsSection('numbering');
});

final receiptSettingsProvider =
    FutureProvider.autoDispose<ReceiptSettingsConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchReceiptSettings();
});

final queueNumberingProvider =
    FutureProvider.autoDispose<QueueNumberingConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).fetchQueueNumbering();
});
