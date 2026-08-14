import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.currency,
    required this.totalTopup,
    required this.totalSpending,
  });

  final double balance;
  final String currency;
  final double totalTopup;
  final double totalSpending;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'IDR',
      totalTopup: (json['totalTopup'] as num?)?.toDouble() ?? 0,
      totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.notes,
    this.referenceNumber,
  });

  final String id;
  final String type;
  final double amount;
  final String createdAt;
  final String? notes;
  final String? referenceNumber;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      notes: (json['notes'] ?? json['description']) as String?,
      referenceNumber: json['referenceNumber'] as String?,
    );
  }
}

class WalletTopUpRequest {
  const WalletTopUpRequest({
    required this.requestId,
    required this.referenceNumber,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.paymentInstructions,
  });

  final String requestId;
  final String referenceNumber;
  final double amount;
  final String paymentMethod;
  final String status;
  final Map<String, dynamic>? paymentInstructions;

  factory WalletTopUpRequest.fromJson(Map<String, dynamic> json) {
    return WalletTopUpRequest(
      requestId: json['requestId'] as String,
      referenceNumber: json['referenceNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paymentInstructions:
          json['paymentInstructions'] as Map<String, dynamic>?,
    );
  }
}

class WalletRepository {
  WalletRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<WalletSummary> getWallet(String customerId) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.wallet;
    }

    final data = await _api.get<Map<String, dynamic>>(
      '/customers/$customerId/wallet',
      parser: (json) => json as Map<String, dynamic>,
    );
    return WalletSummary.fromJson(data);
  }

  Future<PaginatedResponse<WalletTransaction>> getTransactions(
    String customerId, {
    int page = 1,
    String? type,
  }) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.paginatedWalletTransactions;
    }

    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      '/customers/$customerId/wallet/transactions',
      queryParameters: {
        'page': page,
        'limit': AppConfig.defaultPageSize,
        'type': ?type,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data!;
    return PaginatedResponse<WalletTransaction>(
      items: (data['items'] as List<dynamic>)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>),
    );
  }

  Future<WalletTopUpRequest> initiateTopUp({
    required double amount,
    required String paymentMethod,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/customer-app/wallet/top-up',
      data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return WalletTopUpRequest.fromJson(data);
  }

  Future<void> confirmTopUp(String requestId) async {
    await _api.post<Map<String, dynamic>>(
      '/customer-app/wallet/top-up/$requestId/confirm',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<String> getTopUpStatus(String requestId) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/wallet/top-up/$requestId/status',
      parser: (json) => json as Map<String, dynamic>,
    );
    return data['status'] as String? ?? 'pending';
  }
}
