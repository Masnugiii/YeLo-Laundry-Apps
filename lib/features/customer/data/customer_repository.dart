import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/customer/data/customer_mapper.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_statistics.dart';

class CustomerBusinessSummary {
  const CustomerBusinessSummary({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpending,
    required this.averageOrderValue,
    this.lastOrderAt,
  });

  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int totalSpending;
  final int averageOrderValue;
  final DateTime? lastOrderAt;
}

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

  Future<CustomerBusinessSummary> fetchCustomerSummary(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$id/summary',
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerBusinessSummary(
      totalOrders: (data['totalOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (data['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (data['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalSpending: (data['totalSpending'] as num?)?.toInt() ?? 0,
      averageOrderValue: (data['averageOrderValue'] as num?)?.toInt() ?? 0,
      lastOrderAt: data['lastOrderAt'] == null
          ? null
          : DateTime.tryParse(data['lastOrderAt'] as String),
    );
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
        'email': ?email,
        'occupation': ?occupation,
        'addressDetail': ?addressDetail,
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
        'fullName': ?fullName,
        'phone': ?phone,
        'occupation': ?occupation,
        'addressDetail': ?addressDetail,
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

  CustomerStatistics mapSummaryToStatistics(CustomerBusinessSummary summary) {
    return CustomerStatistics(
      totalOrders: summary.totalOrders,
      lastOrder: summary.lastOrderAt == null
          ? '-'
          : _formatDate(summary.lastOrderAt!),
      totalSpending: summary.totalSpending,
      averageOrderValue: summary.averageOrderValue,
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Customer _mapCustomer(Map<String, dynamic> json) => mapCustomerFromJson(json);
}
