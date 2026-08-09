import 'package:yelo_laundry_erp/core/network/api_client.dart';

class PickupDeliveryRepository {
  PickupDeliveryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/pickup-delivery/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPickups({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    return _fetchJobs('/pickups', page: page, limit: limit, search: search);
  }

  Future<List<Map<String, dynamic>>> fetchDeliveries({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    return _fetchJobs('/deliveries', page: page, limit: limit, search: search);
  }

  Future<Map<String, dynamic>> fetchDriverTasks() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/drivers/me/tasks',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchJobs(
    String path, {
    required int page,
    required int limit,
    String? search,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return (data['items'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
}
