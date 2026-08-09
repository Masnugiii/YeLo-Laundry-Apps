class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic value)? fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData != null && fromJsonT != null ? fromJsonT(rawData) : rawData as T?,
    );
  }
}

class PaginatedMeta {
  const PaginatedMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginatedMeta.fromJson(Map<String, dynamic> json) {
    return PaginatedMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.meta,
  });

  final List<T> items;
  final PaginatedMeta meta;
}
