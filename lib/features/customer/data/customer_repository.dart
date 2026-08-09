import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';

class CustomerRepository {
  CustomerRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedResponse<Customer>> fetchCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapCustomer(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<Customer> fetchCustomer(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapCustomer(data);
  }

  Future<Customer> createCustomer({
    required String fullName,
    required String phone,
    String? email,
    String? occupation,
    String? addressDetail,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/customers',
      data: {
        'fullName': fullName,
        'phone': phone,
        if (email != null) 'email': email,
        if (occupation != null) 'occupation': occupation,
        if (addressDetail != null) 'addressDetail': addressDetail,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapCustomer(data);
  }

  Future<Customer> updateCustomer(
    String id, {
    String? fullName,
    String? phone,
    String? occupation,
    String? addressDetail,
  }) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/customers/$id',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (occupation != null) 'occupation': occupation,
        if (addressDetail != null) 'addressDetail': addressDetail,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapCustomer(data);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final data = await _apiClient.get<List<dynamic>>(
      '/customers/search',
      queryParameters: {'q': query},
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => _mapCustomer(item as Map<String, dynamic>))
        .toList();
  }

  Customer _mapCustomer(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      occupation: json['occupation'] as String?,
      address: json['defaultAddress'] as String? ??
          json['addressDetail'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
      points: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      isMember: json['isMember'] as bool? ?? false,
    );
  }
}
