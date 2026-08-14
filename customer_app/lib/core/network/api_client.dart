import 'package:dio/dio.dart';

import 'package:yelo_laundry_customer/core/auth/auth_session_controller.dart';
import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/network/api_interceptors.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({
    required this._secureStorage,
    AuthSessionController? authSession,
    UnauthorizedHandler? onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _refreshDio = Dio(_dio.options);

    _dio.interceptors.addAll([
      LoggerInterceptor(),
      TokenInterceptor(
        secureStorage: _secureStorage,
        refreshDio: _refreshDio,
        authSession: authSession,
        onUnauthorized: onUnauthorized,
      ),
      RetryInterceptor(),
    ]);
  }

  final SecureStorageService _secureStorage;
  late final Dio _dio;
  late final Dio _refreshDio;

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      ),
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      parser: parser,
    );
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      parser: parser,
    );
  }

  Future<T> uploadMultipart<T>(
    String path, {
    required String fileField,
    required String filePath,
    Map<String, dynamic>? fields,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () async {
        final formData = FormData.fromMap({
          ...?fields,
          fileField: await MultipartFile.fromFile(filePath),
        });

        return _dio.post<Map<String, dynamic>>(
          path,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );
      },
      parser: parser,
    );
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    return _request(
      () => _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
      parser: parser,
    );
  }

  Future<T> _request<T>(
    Future<Response<Map<String, dynamic>>> Function() call, {
    T Function(dynamic json)? parser,
  }) async {
    try {
      final response = await call();
      final body = response.data;

      if (body == null) {
        throw const ApiException(
          message: 'Respons server kosong.',
          type: ApiErrorType.unknown,
        );
      }

      if (parser != null) {
        return parser(body['data']);
      }

      return body['data'] as T;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<ApiResponse<T>> getEnvelope<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data ?? {}, parser);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
