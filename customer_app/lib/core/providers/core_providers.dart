import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/auth/data/auth_repository.dart';
import 'package:yelo_laundry_customer/features/home/data/home_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/data/pickup_repository.dart';
import 'package:yelo_laundry_customer/features/profile/data/profile_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final preferencesProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onUnauthorized: () async {
      await ref.read(authProvider.notifier).logout();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
    preferences: ref.watch(preferencesProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(apiClient: ref.watch(apiClientProvider));
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(apiClient: ref.watch(apiClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(apiClient: ref.watch(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(apiClient: ref.watch(apiClientProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(apiClient: ref.watch(apiClientProvider));
});

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository(apiClient: ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(apiClient: ref.watch(apiClientProvider));
});

final pickupRepositoryProvider = Provider<PickupRepository>((ref) {
  return PickupRepository(apiClient: ref.watch(apiClientProvider));
});
