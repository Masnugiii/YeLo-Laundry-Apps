import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/storage/preferences_service.dart';
import 'package:yelo_laundry_erp/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_erp/features/auth/data/auth_repository.dart';
import 'package:yelo_laundry_erp/features/attendance/data/attendance_repository.dart';
import 'package:yelo_laundry_erp/features/catalog/data/catalog_repository.dart';
import 'package:yelo_laundry_erp/features/customer/data/customer_repository.dart';
import 'package:yelo_laundry_erp/features/dashboard/data/dashboard_repository.dart';
import 'package:yelo_laundry_erp/features/employee_master/data/employee_repository.dart';
import 'package:yelo_laundry_erp/features/finance/data/finance_repository.dart';
import 'package:yelo_laundry_erp/features/laundry/data/laundry_repository.dart';
import 'package:yelo_laundry_erp/features/customer_service/data/customer_service_repository.dart';
import 'package:yelo_laundry_erp/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/data/pickup_delivery_repository.dart';
import 'package:yelo_laundry_erp/features/points/data/loyalty_repository.dart';
import 'package:yelo_laundry_erp/features/reports/data/reports_repository.dart';
import 'package:yelo_laundry_erp/features/settings/data/settings_repository.dart';
import 'package:yelo_laundry_erp/features/wallet/data/wallet_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final preferencesServiceProvider = Provider<PreferencesService?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    return null;
  }
  return PreferencesService(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onUnauthorized: () async {
      await secureStorage.clearTokens();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
    preferences: ref.watch(preferencesServiceProvider),
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(apiClientProvider));
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(apiClientProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(apiClientProvider));
});

final laundryRepositoryProvider = Provider<LaundryRepository>((ref) {
  return LaundryRepository(ref.watch(apiClientProvider));
});

final pickupDeliveryRepositoryProvider =
    Provider<PickupDeliveryRepository>((ref) {
  return PickupDeliveryRepository(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final customerServiceRepositoryProvider =
    Provider<CustomerServiceRepository>((ref) {
  return CustomerServiceRepository(ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(apiClientProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(apiClientProvider));
});

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return LoyaltyRepository(ref.watch(apiClientProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.watch(apiClientProvider));
});
