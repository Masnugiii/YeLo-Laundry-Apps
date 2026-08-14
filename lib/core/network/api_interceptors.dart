import 'package:dio/dio.dart';

import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/storage/secure_storage_service.dart';

typedef UnauthorizedHandler = Future<void> Function();

class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required this._secureStorage,
    required this._refreshDio,
    this.onUnauthorized,
  });

  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  final UnauthorizedHandler? onUnauthorized;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
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

    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await onUnauthorized?.call();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null) {
        await onUnauthorized?.call();
        handler.next(err);
        return;
      }

      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );
      handler.resolve(retryResponse);

      for (final pending in _pendingRequests) {
        final pendingResponse = await _retryRequest(
          pending.options,
          newAccessToken,
        );
        pending.handler.resolve(pendingResponse);
      }
      _pendingRequests.clear();
    } catch (_) {
      await onUnauthorized?.call();
      handler.next(err);
    } finally {
      _isRefreshing = false;
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
