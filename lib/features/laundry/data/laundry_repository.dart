import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';

class LaundryRepository {
  LaundryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/laundry/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<PaginatedResponse<Map<String, dynamic>>> fetchQueue({
    int page = 1,
    int limit = 20,
    String? search,
    String? stage,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/laundry/orders',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (stage != null) 'stage': stage,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}
