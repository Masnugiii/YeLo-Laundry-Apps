import 'package:dio/dio.dart';

import 'package:yelo_laundry_customer/core/auth/auth_debug_log.dart';
import 'package:yelo_laundry_customer/core/auth/auth_session_controller.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';

typedef UnauthorizedHandler = Future<void> Function(int requestEpoch);

const _authRetriedKey = 'authRetried';
const _authEpochKey = 'authEpoch';

bool isAuthLogoutRequest(RequestOptions options) {
  return options.method.toUpperCase() == 'POST' &&
      (options.path == '/auth/logout' || options.path.endsWith('/auth/logout'));
}

bool isAuthRefreshRequest(RequestOptions options) {
  return options.method.toUpperCase() == 'POST' &&
      (options.path == '/auth/refresh' || options.path.endsWith('/auth/refresh'));
}

class TokenRefreshResult {
  const TokenRefreshResult({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
}

TokenRefreshResult? parseTokenRefreshResponse(Map<String, dynamic>? body) {
  if (body == null) return null;

  final data = body['data'];
  if (data is! Map<String, dynamic>) return null;

  final accessToken = data['accessToken'] as String?;
  if (accessToken == null || accessToken.isEmpty) return null;

  return TokenRefreshResult(
    accessToken: accessToken,
    refreshToken: data['refreshToken'] as String?,
  );
}

class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required this._secureStorage,
    required this._refreshDio,
    this._authSession,
    this.onUnauthorized,
  });

  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  final AuthSessionController? _authSession;
  final UnauthorizedHandler? onUnauthorized;

  bool _isRefreshing = false;
  Future<String>? _ongoingRefresh;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_authSession != null) {
      options.extra[_authEpochKey] = _authSession.epoch;
    }

    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();

    authDebugLog(
      'access token ${accessToken != null && accessToken.isNotEmpty ? 'present' : 'missing'}',
    );
    authDebugLog(
      'refresh token ${refreshToken != null && refreshToken.isNotEmpty ? 'present' : 'missing'}',
    );

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isStaleAuthRequest(err.requestOptions)) {
      authDebugLog('401 from stale auth epoch ignored');
      handler.next(err);
      return;
    }

    if (isAuthLogoutRequest(err.requestOptions)) {
      handler.next(err);
      return;
    }

    if (isAuthRefreshRequest(err.requestOptions)) {
      authDebugLog('refresh failed → logout');
      await _rejectPendingRequests(err);
      if (!_isStaleAuthRequest(err.requestOptions)) {
        await _triggerUnauthorized(err.requestOptions);
      }
      handler.next(err);
      return;
    }

    if (err.requestOptions.extra[_authRetriedKey] == true) {
      authDebugLog('request already retried after refresh → logout');
      if (!_isStaleAuthRequest(err.requestOptions)) {
        await _triggerUnauthorized(err.requestOptions);
      }
      handler.next(err);
      return;
    }

    authDebugLog('access token expired/401');

    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      authDebugLog('refresh token missing → logout');
      if (!_isStaleAuthRequest(err.requestOptions)) {
        await _triggerUnauthorized(err.requestOptions);
      }
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    authDebugLog('refresh started');

    try {
      final newAccessToken = await _refreshAccessToken(refreshToken);

      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );
      authDebugLog('retry original request');
      handler.resolve(retryResponse);

      final pending = List.of(_pendingRequests);
      _pendingRequests.clear();
      for (final request in pending) {
        try {
          final pendingResponse = await _retryRequest(
            request.options,
            newAccessToken,
          );
          request.handler.resolve(pendingResponse);
        } on DioException catch (pendingError) {
          request.handler.next(pendingError);
        }
      }
    } catch (error) {
      if (error is DioException && _isTransientError(error)) {
        authDebugLog('refresh transient error → no logout');
        await _rejectPendingRequests(err);
        handler.next(err);
        return;
      }

      authDebugLog('refresh failed → logout');
      await _rejectPendingRequests(err);
      if (!_isStaleAuthRequest(err.requestOptions)) {
        await _triggerUnauthorized(err.requestOptions);
      }
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  bool _isStaleAuthRequest(RequestOptions options) {
    final session = _authSession;
    if (session == null) return false;
    return _requestEpoch(options) != session.epoch;
  }

  bool _isTransientError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  int _requestEpoch(RequestOptions options) {
    return options.extra[_authEpochKey] as int? ?? _authSession?.epoch ?? 0;
  }

  Future<void> _triggerUnauthorized(RequestOptions options) async {
    await onUnauthorized?.call(_requestEpoch(options));
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    if (_ongoingRefresh != null) {
      return _ongoingRefresh!;
    }

    final refreshFuture = _performRefresh(refreshToken);
    _ongoingRefresh = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      _ongoingRefresh = null;
    }
  }

  Future<String> _performRefresh(String refreshToken) async {
    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final refreshResult = parseTokenRefreshResponse(response.data);
    if (refreshResult == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh', method: 'POST'),
        message: 'Invalid refresh response',
      );
    }

    await _secureStorage.saveTokens(
      accessToken: refreshResult.accessToken,
      refreshToken: refreshResult.refreshToken,
    );
    authDebugLog('refresh success');
    return refreshResult.accessToken;
  }

  Future<void> _rejectPendingRequests(DioException err) async {
    final pending = List.of(_pendingRequests);
    _pendingRequests.clear();
    for (final request in pending) {
      request.handler.next(err);
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
      extra: {
        ...requestOptions.extra,
        _authRetriedKey: true,
      },
    );

    return _refreshDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 2});

  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (!shouldRetry || retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 300 * (retryCount + 1)));

    try {
      final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
      final response = await dio.fetch<dynamic>(
        err.requestOptions.copyWith(
          extra: {
            ...err.requestOptions.extra,
            'retryCount': retryCount + 1,
          },
        ),
      );
      handler.resolve(response);
    } catch (error) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

ApiException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return const ApiException(
      message: 'Permintaan timeout. Periksa koneksi Anda.',
      type: ApiErrorType.timeout,
    );
  }

  if (error.type == DioExceptionType.connectionError) {
    return const ApiException(
      message: 'Tidak ada koneksi internet.',
      type: ApiErrorType.offline,
    );
  }

  if (error.type == DioExceptionType.cancel) {
    return const ApiException(
      message: 'Permintaan dibatalkan.',
      type: ApiErrorType.cancelled,
    );
  }

  final statusCode = error.response?.statusCode;
  final responseData = error.response?.data;
  final message = responseData is Map<String, dynamic>
      ? responseData['message'] as String? ?? 'Terjadi kesalahan.'
      : 'Terjadi kesalahan.';

  switch (statusCode) {
    case 401:
      return ApiException(
        message: message,
        type: ApiErrorType.unauthorized,
        statusCode: statusCode,
      );
    case 403:
      return ApiException(
        message: message,
        type: ApiErrorType.forbidden,
        statusCode: statusCode,
      );
    case 404:
      return ApiException(
        message: message,
        type: ApiErrorType.notFound,
        statusCode: statusCode,
      );
    case 422:
      return ApiException(
        message: message,
        type: ApiErrorType.validation,
        statusCode: statusCode,
        errors: responseData is Map<String, dynamic> ? responseData['errors'] : null,
      );
    default:
      if ((statusCode ?? 0) >= 500) {
        return ApiException(
          message: message,
          type: ApiErrorType.server,
          statusCode: statusCode,
        );
      }
      return ApiException(
        message: message,
        type: ApiErrorType.unknown,
        statusCode: statusCode,
      );
  }
}
