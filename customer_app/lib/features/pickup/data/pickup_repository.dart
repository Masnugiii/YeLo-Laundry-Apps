import 'package:yelo_laundry_customer/core/network/api_client.dart';

class PickupRepository {
  PickupRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<Map<String, dynamic>> createPickupRequest({
    required String orderId,
    String? pickupAddressId,
    DateTime? scheduledPickupAt,
    String? notes,
  }) async {
    return _api.post<Map<String, dynamic>>(
      '/customer-app/pickup-requests',
      data: {
        'orderId': orderId,
        if (pickupAddressId != null) 'pickupAddressId': pickupAddressId,
        if (scheduledPickupAt != null)
          'scheduledPickupAt': scheduledPickupAt.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
