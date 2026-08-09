import 'package:yelo_laundry_erp/core/network/api_client.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchOwnerSummary() async {
    final results = await Future.wait([
      _apiClient.get<Map<String, dynamic>>(
        '/finance/dashboard',
        parser: (json) => json as Map<String, dynamic>,
      ),
      _apiClient.get<Map<String, dynamic>>(
        '/orders/statistics',
        parser: (json) => json as Map<String, dynamic>,
      ),
      _apiClient.get<Map<String, dynamic>>(
        '/attendance/dashboard',
        parser: (json) => json as Map<String, dynamic>,
      ),
      _apiClient.get<Map<String, dynamic>>(
        '/laundry/dashboard',
        parser: (json) => json as Map<String, dynamic>,
      ),
      _apiClient.get<Map<String, dynamic>>(
        '/pickup-delivery/dashboard',
        parser: (json) => json as Map<String, dynamic>,
      ),
      _apiClient.get<Map<String, dynamic>>(
        '/notifications/unread-count',
        parser: (json) => json as Map<String, dynamic>,
      ),
    ]);

    return {
      'finance': results[0],
      'orders': results[1],
      'attendance': results[2],
      'laundry': results[3],
      'pickupDelivery': results[4],
      'notifications': results[5],
    };
  }
}
