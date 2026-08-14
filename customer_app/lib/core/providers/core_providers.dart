import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/auth/auth_session_controller.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/auth/data/auth_repository.dart';
import 'package:yelo_laundry_customer/features/catalog/data/catalog_repository.dart';
import 'package:yelo_laundry_customer/features/claim_point/data/mission_repository.dart';
import 'package:yelo_laundry_customer/features/help/data/support_repository.dart';
import 'package:yelo_laundry_customer/features/home/data/home_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_feedback_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/data/laundry_checkout_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/data/payment_config_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/data/pickup_repository.dart';
import 'package:yelo_laundry_customer/features/profile/data/profile_repository.dart';
import 'package:yelo_laundry_customer/features/promo/data/promo_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

final authSessionControllerProvider = Provider<AuthSessionController>((ref) {
  ref.keepAlive();
  return AuthSessionController();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  ref.keepAlive();
  return SecureStorageService();
});

final preferencesProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  ref.keepAlive();
  final secureStorage = ref.watch(secureStorageProvider);
  final authSession = ref.watch(authSessionControllerProvider);
  return ApiClient(
    secureStorage: secureStorage,
    authSession: authSession,
    onUnauthorized: (requestEpoch) async {
      await ref
          .read(authProvider.notifier)
          .handleUnauthorized(requestEpoch);
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

final orderFeedbackRepositoryProvider = Provider<OrderFeedbackRepository>((ref) {
  return OrderFeedbackRepository(apiClient: ref.watch(apiClientProvider));
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

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(apiClient: ref.watch(apiClientProvider));
});

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository(apiClient: ref.watch(apiClientProvider));
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(apiClient: ref.watch(apiClientProvider));
});

final laundryCheckoutRepositoryProvider = Provider<LaundryCheckoutRepository>((ref) {
  return LaundryCheckoutRepository(apiClient: ref.watch(apiClientProvider));
});

final paymentConfigRepositoryProvider = Provider<PaymentConfigRepository>((ref) {
  return PaymentConfigRepository(apiClient: ref.watch(apiClientProvider));
});

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository(apiClient: ref.watch(apiClientProvider));
});
