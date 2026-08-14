import 'package:yelo_laundry_erp/core/network/api_client.dart';

class LaciLaundryRepository {
  LaciLaundryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() {
    return _apiClient.get<Map<String, dynamic>>(
      '/storage/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> fetchLockers() async {
    final data = await _apiClient.get<List<dynamic>>(
      '/storage/lockers',
      parser: (json) => json as List<dynamic>,
    );
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> fetchLocker(String code) {
    return _apiClient.get<Map<String, dynamic>>(
      '/storage/lockers/$code',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> fetchBox(String code) {
    return _apiClient.get<Map<String, dynamic>>(
      '/storage/boxes/$code',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAvailableBoxes(String lockerCode) async {
    final data = await _apiClient.get<List<dynamic>>(
      '/storage/lockers/$lockerCode/available',
      parser: (json) => json as List<dynamic>,
    );
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> searchBoxes({
    String? q,
    String? lockerCode,
    String? status,
  }) {
    return _apiClient.get<Map<String, dynamic>>(
      '/storage/boxes/search',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (lockerCode != null && lockerCode.isNotEmpty) 'lockerCode': lockerCode,
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': 100,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> assignStorage({
    required String orderId,
    required String lockerCode,
    required int boxNumber,
  }) {
    return _apiClient.post<Map<String, dynamic>>(
      '/storage/orders/$orderId/assign',
      data: {
        'lockerCode': lockerCode,
        'boxNumber': boxNumber,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> moveStorage({
    required String orderId,
    required String lockerCode,
    required int boxNumber,
  }) {
    return _apiClient.patch<Map<String, dynamic>>(
      '/storage/orders/$orderId/move',
      data: {
        'lockerCode': lockerCode,
        'boxNumber': boxNumber,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> fetchOrderStorage(String orderId) {
    return _apiClient.get<Map<String, dynamic>>(
      '/storage/orders/$orderId',
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
