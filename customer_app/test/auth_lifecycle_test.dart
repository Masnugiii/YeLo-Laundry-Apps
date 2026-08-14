import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/features/auth/data/auth_repository.dart';

class _FakeSecureStorage extends SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<String?> getAccessToken() async => _values['access_token'];

  @override
  Future<String?> getRefreshToken() async => _values['refresh_token'];

  @override
  Future<void> saveAccessToken(String token) async {
    _values['access_token'] = token;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _values['refresh_token'] = token;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _values['access_token'] = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _values['refresh_token'] = refreshToken;
    }
  }

  @override
  Future<void> clearTokens() async {
    _values.clear();
  }
}

class _LoginApiClient extends ApiClient {
  _LoginApiClient({
    required super.secureStorage,
  });

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    if (parser == null) {
      throw UnimplementedError('parser required');
    }

    if (path == '/auth/profile') {
      return parser({
        'id': 'cust-1',
        'fullName': 'Test User',
        'phone': '081234567890',
        'customerCode': 'CUS-0004827',
      });
    }

    throw UnimplementedError('Unexpected GET $path');
  }

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    if (path == '/auth/otp/verify' && parser != null) {
      return parser({
        'accessToken': 'access-token-1',
        'refreshToken': 'refresh-token-1',
        'user': {
          'id': 'cust-1',
          'fullName': 'Test User',
          'phone': '081234567890',
        },
      });
    }

    throw UnimplementedError('Unexpected POST $path');
  }
}

class _AuthenticatedApiClient extends ApiClient {
  _AuthenticatedApiClient({
    required super.secureStorage,
    super.authSession,
  });

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    if (parser == null) {
      throw UnimplementedError('parser required');
    }

    if (path == '/customer-app/missions') {
      return parser([
        {
          'id': 'mission-1',
          'type': 'quiz',
          'title': 'Quiz',
          'description': 'Selesaikan quiz',
          'rewardPoints': 50,
          'status': 'available',
          'ctaLabel': 'Mulai',
        },
      ]);
    }

    if (path == '/customer-app/rewards') {
      return parser({
        'currentPoints': 1250,
        'expiredPoints': 0,
      });
    }

    if (path == '/auth/profile') {
      return parser({
        'id': 'cust-1',
        'fullName': 'Test User',
        'phone': '081234567890',
        'customerCode': 'CUS-0004827',
      });
    }

    throw UnimplementedError('Unexpected GET $path');
  }
}

class _SlowRestoreAuthRepository extends AuthRepository {
  _SlowRestoreAuthRepository({
    required super.apiClient,
    required super.secureStorage,
    required super.preferences,
    required this.delay,
  });

  final Duration delay;

  @override
  Future<CustomerSession?> restoreSession() async {
    await Future<void>.delayed(delay);
    return null;
  }
}

class _CountingRestoreAuthRepository extends AuthRepository {
  _CountingRestoreAuthRepository({
    required super.apiClient,
    required super.secureStorage,
    required super.preferences,
    required this.onRestore,
  });

  final void Function() onRestore;

  @override
  Future<CustomerSession?> restoreSession() async {
    onRestore();
    return super.restoreSession();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth token persistence', () {
    late _FakeSecureStorage storage;
    late PreferencesService preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = _FakeSecureStorage();
      preferences = PreferencesService();
    });

    test('login saves access and refresh token', () async {
      final repository = AuthRepository(
        apiClient: _LoginApiClient(secureStorage: storage),
        secureStorage: storage,
        preferences: preferences,
      );

      await repository.verifyOtp(
        otpRequestId: 'otp-1',
        phone: '081234567890',
        otpCode: '123456',
      );

      expect(await storage.getAccessToken(), 'access-token-1');
      expect(await storage.getRefreshToken(), 'refresh-token-1');
    });

    test('login loads member serial from profile', () async {
      final repository = AuthRepository(
        apiClient: _LoginApiClient(secureStorage: storage),
        secureStorage: storage,
        preferences: preferences,
      );

      final session = await repository.verifyOtp(
        otpRequestId: 'otp-1',
        phone: '081234567890',
        otpCode: '123456',
      );

      expect(session.memberSerialNumber, 'CUS-0004827');

      final cached = await preferences.readCustomerProfile();
      expect(cached?.memberSerialNumber, 'CUS-0004827');
    });

    test('saved tokens can immediately be read back', () async {
      await storage.saveTokens(
        accessToken: 'access-token-2',
        refreshToken: 'refresh-token-2',
      );

      expect(await storage.getAccessToken(), 'access-token-2');
      expect(await storage.getRefreshToken(), 'refresh-token-2');
    });
  });

  group('AuthNotifier lifecycle', () {
    late _FakeSecureStorage storage;
    late PreferencesService preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = _FakeSecureStorage();
      preferences = PreferencesService();
    });

    Future<AuthNotifier> waitForInitialRestore(ProviderContainer container) async {
      final notifier = container.read(authProvider.notifier);
      while (container.read(authProvider).status == AuthStatus.initial ||
          container.read(authProvider).status == AuthStatus.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return notifier;
    }

    test('restoreSession only runs once on cold start', () async {
      var restoreCalls = 0;
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(
            _LoginApiClient(secureStorage: storage),
          ),
          authRepositoryProvider.overrideWith((ref) {
            return _CountingRestoreAuthRepository(
              apiClient: ref.watch(apiClientProvider),
              secureStorage: storage,
              preferences: preferences,
              onRestore: () => restoreCalls++,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await waitForInitialRestore(container);

      expect(restoreCalls, 1);
    });

    test('completeAuth wins over stale restoreSession', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(
            _LoginApiClient(secureStorage: storage),
          ),
          authRepositoryProvider.overrideWith((ref) {
            return _SlowRestoreAuthRepository(
              apiClient: ref.watch(apiClientProvider),
              secureStorage: storage,
              preferences: preferences,
              delay: const Duration(milliseconds: 120),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      final restoreFuture = notifier.restoreSession();

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await storage.saveTokens(
        accessToken: 'access-token-1',
        refreshToken: 'refresh-token-1',
      );
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      await restoreFuture;

      expect(
        container.read(authProvider).status,
        AuthStatus.authenticated,
      );
      expect(container.read(authProvider).session.id, 'cust-1');
    });

    test('restoreSession cannot clear a newer login', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(
            _LoginApiClient(secureStorage: storage),
          ),
          authRepositoryProvider.overrideWith((ref) {
            return _SlowRestoreAuthRepository(
              apiClient: ref.watch(apiClientProvider),
              secureStorage: storage,
              preferences: preferences,
              delay: const Duration(milliseconds: 80),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      final restoreFuture = notifier.restoreSession();

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await storage.saveTokens(
        accessToken: 'access-token-new',
        refreshToken: 'refresh-token-new',
      );
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-new',
          fullName: 'New User',
          phone: '081111111111',
        ),
      );

      await restoreFuture;

      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(authProvider).session.id, 'cust-new');
      expect(await storage.getAccessToken(), 'access-token-new');
    });

    test('handleUnauthorized clears session only once when authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(
            _LoginApiClient(secureStorage: storage),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = await waitForInitialRestore(container);
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      final epoch = container.read(authSessionControllerProvider).epoch;
      await Future.wait([
        notifier.handleUnauthorized(epoch),
        notifier.handleUnauthorized(epoch),
      ]);

      expect(
        container.read(authProvider).status,
        AuthStatus.unauthenticated,
      );
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('stale handleUnauthorized does not clear newer login tokens', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(
            _LoginApiClient(secureStorage: storage),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = await waitForInitialRestore(container);
      await storage.saveTokens(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
      );
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      final staleEpoch = container.read(authSessionControllerProvider).epoch - 1;

      await storage.saveTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      );
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-2',
          fullName: 'New User',
          phone: '081999999999',
        ),
      );

      await notifier.handleUnauthorized(staleEpoch);

      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(await storage.getAccessToken(), 'new-access');
      expect(await storage.getRefreshToken(), 'new-refresh');
    });
  });

  group('Authenticated API access', () {
    late _FakeSecureStorage storage;
    late PreferencesService preferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = _FakeSecureStorage();
      preferences = PreferencesService();
    });

    Future<void> waitForInitialRestore(ProviderContainer container) async {
      while (container.read(authProvider).status == AuthStatus.initial ||
          container.read(authProvider).status == AuthStatus.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }

    test('valid login then missions succeeds', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWith((ref) {
            return _AuthenticatedApiClient(
              secureStorage: storage,
              authSession: ref.watch(authSessionControllerProvider),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await waitForInitialRestore(container);
      await storage.saveTokens(
        accessToken: 'access-token-1',
        refreshToken: 'refresh-token-1',
      );
      await container.read(authProvider.notifier).completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      final missions = await container
          .read(missionRepositoryProvider)
          .fetchMissions();

      expect(missions, hasLength(1));
      expect(missions.first.id, 'mission-1');
    });

    test('valid login then rewards succeeds', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWith((ref) {
            return _AuthenticatedApiClient(
              secureStorage: storage,
              authSession: ref.watch(authSessionControllerProvider),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await waitForInitialRestore(container);
      await storage.saveTokens(
        accessToken: 'access-token-1',
        refreshToken: 'refresh-token-1',
      );
      await container.read(authProvider.notifier).completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      final summary = await container
          .read(rewardRepositoryProvider)
          .getSummary();

      expect(summary.currentPoints, 1250);
    });
  });
}
