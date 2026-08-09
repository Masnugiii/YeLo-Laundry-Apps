import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<CustomerSession> updateProfile({
    required String fullName,
    String? email,
    String? photoUrl,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/auth/profile',
      data: {
        'fullName': fullName,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerSession(
      id: data['id'] as String,
      fullName: data['fullName'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}
