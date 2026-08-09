import 'package:yelo_laundry_erp/core/network/api_client.dart';

class AttendanceRepository {
  AttendanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/attendance/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> payload) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/attendance/check-in',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> checkOut(String attendanceId) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/attendance/$attendanceId/check-out',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> fetchHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/attendance',
      queryParameters: {'page': page, 'limit': limit},
      parser: (json) => json as Map<String, dynamic>,
    );

    return (data['items'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }
}
