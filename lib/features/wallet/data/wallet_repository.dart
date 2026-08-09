import 'package:yelo_laundry_erp/core/network/api_client.dart';

class CustomerWalletSummary {
  const CustomerWalletSummary({
    required this.walletId,
    required this.customerId,
    required this.balance,
    required this.currency,
    required this.isActive,
  });

  final String walletId;
  final String customerId;
  final double balance;
  final String currency;
  final bool isActive;
}

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CustomerWalletSummary> fetchCustomerWallet(String customerId) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$customerId/wallet',
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapWalletSummary(data);
  }

  Future<Map<String, dynamic>> topUp(
    String customerId, {
    required double amount,
    String? notes,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/customers/$customerId/wallet/topup',
      data: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> deduct(
    String customerId, {
    required double amount,
    String? notes,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/customers/$customerId/wallet/deduct',
      data: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(
    String customerId, {
    int page = 1,
    int limit = 50,
    String? type,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$customerId/wallet/transactions',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null && type.isNotEmpty) 'type': type,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return (data['items'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  CustomerWalletSummary _mapWalletSummary(Map<String, dynamic> json) {
    return CustomerWalletSummary(
      walletId: json['walletId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'IDR',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
