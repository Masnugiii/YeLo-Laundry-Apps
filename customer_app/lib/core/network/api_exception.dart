enum ApiErrorType {
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  timeout,
  offline,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.errors,
  });

  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic errors;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  @override
  String toString() => message;
}
