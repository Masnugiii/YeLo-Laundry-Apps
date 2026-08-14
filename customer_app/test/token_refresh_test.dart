import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/auth/auth_session_controller.dart';
import 'package:yelo_laundry_customer/core/network/api_interceptors.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';

class _FakeSecureStorage extends SecureStorageService {
  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    this.accessToken = accessToken;
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  group('parseTokenRefreshResponse', () {
    test('parses access and refresh token from envelope', () {
      final result = parseTokenRefreshResponse({
        'success': true,
        'message': 'Token refreshed successfully',
        'data': {
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        },
      });

      expect(result?.accessToken, 'new-access');
      expect(result?.refreshToken, 'new-refresh');
    });
  });

  group('TokenInterceptor refresh', () {
    test('expired access token refreshes and retries original request', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'valid-refresh';

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'));
      refreshDio.httpClientAdapter = _MockAdapter(refreshDio);

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(
        path: '/customer-app/rewards',
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
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(unauthorizedCalls, 0);
      expect(handler.resolved, isTrue);
      expect(storage.accessToken, 'new-access');
      expect(storage.refreshToken, 'new-refresh');
    });

    test('invalid refresh token clears session via onUnauthorized', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'invalid-refresh';

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'));
      refreshDio.httpClientAdapter = _MockAdapter(
        refreshDio,
        refreshStatusCode: 401,
      );

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(
        path: '/customer-app/rewards',
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
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(unauthorizedCalls, 1);
      expect(handler.forwarded, isTrue);
      expect(handler.resolved, isFalse);
    });

    test('refresh endpoint 401 does not recurse refresh', () async {
      final storage = _FakeSecureStorage()..refreshToken = 'invalid-refresh';

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: Dio(),
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(
        path: '/auth/refresh',
        method: 'POST',
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

    test('multiple simultaneous 401 requests share one refresh', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'valid-refresh';

      final adapter = _CountingMockAdapter();
      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'));
      refreshDio.httpClientAdapter = adapter;

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final first = RequestOptions(path: '/customer-app/rewards', method: 'GET');
      final second = RequestOptions(path: '/customer-app/missions', method: 'GET');

      final handler1 = _RecordingErrorHandler();
      final handler2 = _RecordingErrorHandler();

      interceptor.onError(
        DioException(
          requestOptions: first,
          response: Response(requestOptions: first, statusCode: 401),
        ),
        handler1,
      );
      interceptor.onError(
        DioException(
          requestOptions: second,
          response: Response(requestOptions: second, statusCode: 401),
        ),
        handler2,
      );

      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(adapter.refreshCalls, 1);
      expect(unauthorizedCalls, 0);
      expect(handler1.resolved, isTrue);
      expect(handler2.resolved, isTrue);
    });

    test('refresh network error does not logout', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'valid-refresh';

      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'));
      refreshDio.httpClientAdapter = _NetworkErrorAdapter();

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: refreshDio,
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
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(unauthorizedCalls, 0);
      expect(handler.forwarded, isTrue);
      expect(handler.resolved, isFalse);
    });

    test('stale auth epoch 401 does not logout', () async {
      final storage = _FakeSecureStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'valid-refresh';
      final authSession = AuthSessionController()..bump();

      var unauthorizedCalls = 0;
      final interceptor = TokenInterceptor(
        secureStorage: storage,
        refreshDio: Dio(),
        authSession: authSession,
        onUnauthorized: (requestEpoch) async {
          unauthorizedCalls++;
        },
      );

      final requestOptions = RequestOptions(
        path: '/customer-app/missions',
        method: 'GET',
        extra: {'authEpoch': 0},
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

      expect(unauthorizedCalls, 0);
      expect(handler.forwarded, isTrue);
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

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.dio, {this.refreshStatusCode = 200});

  final Dio dio;
  final int refreshStatusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      if (refreshStatusCode == 401) {
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
          ),
        );
      }

      return ResponseBody.fromString(
        '{"success":true,"data":{"accessToken":"new-access","refreshToken":"new-refresh"}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path == '/customer-app/rewards' ||
        options.path == '/customer-app/missions') {
      final auth = options.headers['Authorization'];
      if (auth == 'Bearer new-access') {
        return ResponseBody.fromString(
          '{"success":true,"data":{}}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }

      return ResponseBody.fromString('{"message":"Unauthorized"}', 401);
    }

    return ResponseBody.fromString('{"message":"not found"}', 404);
  }
}

class _CountingMockAdapter extends _MockAdapter {
  _CountingMockAdapter() : super(Dio());

  int refreshCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshCalls++;
    }
    return super.fetch(options, requestStream, cancelFuture);
  }
}

class _NetworkErrorAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: 'offline',
    );
  }
}
