import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_interceptors.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/features/auth/data/auth_repository.dart';

class _FakeSecureStorage extends SecureStorageService {
  _FakeSecureStorage();

  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _CountingLogoutApiClient extends ApiClient {
  _CountingLogoutApiClient({required super.secureStorage});

  int logoutPostCount = 0;

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    if (path == '/auth/logout') {
      logoutPostCount++;
      throw DioException(
        requestOptions: RequestOptions(path: path, method: 'POST'),
        response: Response(
          requestOptions: RequestOptions(path: path, method: 'POST'),
          statusCode: 401,
        ),
      );
    }

    throw UnimplementedError('Unexpected POST $path');
  }
}

class _DelayedLogoutAuthRepository extends AuthRepository {
  _DelayedLogoutAuthRepository({
    required super.apiClient,
    required super.secureStorage,
    required super.preferences,
    required this.onLogoutInvoked,
  });

  final void Function() onLogoutInvoked;

  @override
  Future<void> logout() async {
    onLogoutInvoked();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await super.logout();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('isAuthLogoutRequest', () {
    test('matches POST /auth/logout', () {
      expect(
        isAuthLogoutRequest(
          RequestOptions(path: '/auth/logout', method: 'POST'),
        ),
        isTrue,
      );
    });

    test('does not match other endpoints', () {
      expect(
        isAuthLogoutRequest(
          RequestOptions(path: '/customer-app/missions', method: 'GET'),
        ),
        isFalse,
      );
      expect(
        isAuthLogoutRequest(
          RequestOptions(path: '/auth/logout', method: 'GET'),
        ),
        isFalse,
      );
    });
  });

  group('TokenInterceptor', () {
    test('logout 401 does not invoke onUnauthorized or refresh', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'refresh-token';

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: Dio(),
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(path: '/auth/logout', method: 'POST');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      final handler = _RecordingErrorHandler();
      interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      expect(unauthorizedCalls, 0);
      expect(handler.forwarded, isTrue);
      expect(handler.resolved, isFalse);
    });

    test('non-logout 401 without refresh token invokes onUnauthorized once', () async {
      final storage = _FakeSecureStorage();

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: Dio(),
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(
        path: '/customer-app/missions',
        method: 'GET',
      );
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      final handler = _RecordingErrorHandler();
      interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      expect(unauthorizedCalls, 1);
      expect(handler.forwarded, isTrue);
    });
  });

  group('AuthNotifier.logout', () {
    late _FakeSecureStorage secureStorage;
    late PreferencesService preferences;
    late _CountingLogoutApiClient apiClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      secureStorage = _FakeSecureStorage();
      preferences = PreferencesService();
      await preferences.saveCustomerProfile(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );
      apiClient = _CountingLogoutApiClient(secureStorage: secureStorage);
    });

    Future<AuthNotifier> waitForAuthNotifier(ProviderContainer container) async {
      final notifier = container.read(authProvider.notifier);
      while (container.read(authProvider).status == AuthStatus.initial ||
          container.read(authProvider).status == AuthStatus.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return notifier;
    }

    test('expired token logout clears local session with one API attempt', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(apiClient),
          authRepositoryProvider.overrideWith((ref) {
            return AuthRepository(
              apiClient: apiClient,
              secureStorage: secureStorage,
              preferences: preferences,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = await waitForAuthNotifier(container);
      secureStorage.accessToken = 'token';
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      await notifier.logout();

      expect(apiClient.logoutPostCount, 1);
      expect(await secureStorage.getAccessToken(), isNull);
      expect(
        container.read(authProvider).status,
        AuthStatus.unauthenticated,
      );
    });

    test('concurrent logout runs only one repository logout', () async {
      var repositoryLogoutCalls = 0;
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          preferencesProvider.overrideWithValue(preferences),
          apiClientProvider.overrideWithValue(apiClient),
          authRepositoryProvider.overrideWith((ref) {
            return _DelayedLogoutAuthRepository(
              apiClient: apiClient,
              secureStorage: secureStorage,
              preferences: preferences,
              onLogoutInvoked: () => repositoryLogoutCalls++,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = await waitForAuthNotifier(container);
      secureStorage.accessToken = 'token';
      await notifier.completeAuth(
        const CustomerSession(
          id: 'cust-1',
          fullName: 'Test User',
          phone: '081234567890',
        ),
      );

      await Future.wait([
        notifier.logout(),
        notifier.logout(),
      ]);

      expect(repositoryLogoutCalls, 1);
      expect(
        container.read(authProvider).status,
        AuthStatus.unauthenticated,
      );
    });
  });
}

class _RecordingErrorHandler extends ErrorInterceptorHandler {
  bool forwarded = false;
  bool resolved = false;

  @override
  void next(DioException err) {
    forwarded = true;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolved = true;
  }
}
