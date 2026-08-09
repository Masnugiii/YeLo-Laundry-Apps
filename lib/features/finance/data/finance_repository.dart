import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';
import 'package:yelo_laundry_erp/features/payments/models/payment_transaction.dart';

class FinanceRepository {
  FinanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/finance/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<PaginatedResponse<PaymentTransaction>> fetchPayments({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/payments',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapPayment(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<PaginatedResponse<Expense>> fetchExpenses({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/expenses',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapExpense(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> payload) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/payments',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );

    final paymentMethod = data['paymentMethod'];

    return {
      'id': data['id'],
      'referenceNumber': data['referenceNumber'],
      'amount': (data['amount'] as num?)?.toDouble() ?? 0,
      'paymentMethod': paymentMethod is Map<String, dynamic>
          ? paymentMethod['apiCode'] ?? paymentMethod['code']
          : paymentMethod,
      'paidAt': data['paidAt'],
    };
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> payload) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/expenses',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchExpenseCategories() async {
    final data = await _apiClient.get<List<dynamic>>(
      '/expenses/categories',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  PaymentTransaction _mapPayment(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toInt() ?? 0;
    final paidAt = DateTime.tryParse(json['paidAt'] as String? ?? '') ??
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();

    return PaymentTransaction(
      customerName: json['customerName'] as String? ?? '',
      queueNumber: json['orderNumber'] as String? ?? json['referenceNumber'] as String? ?? '',
      service: LaundryServiceType.regular,
      weightKg: 0,
      totalPayment: 'Rp${_formatAmount(amount)}',
      paymentMethod: _mapPaymentMethod(json['paymentMethod'] as String?),
      pickupDelivery: PaymentPickupDelivery.datangSendiri,
      laundryStatus: PaymentLaundryStatus.menunggu,
      paymentTime:
          '${paidAt.hour.toString().padLeft(2, '0')}:${paidAt.minute.toString().padLeft(2, '0')} WIB',
      paidAt: paidAt,
    );
  }

  Expense _mapExpense(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      category: ExpenseCategory.lainnya,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      adminName: json['createdByName'] as String? ?? 'Admin',
      dateTime: DateTime.tryParse(json['expenseDate'] as String? ?? '') ??
          DateTime.now(),
      description: json['notes'] as String? ?? json['title'] as String?,
    );
  }

  PaymentMethod _mapPaymentMethod(String? method) {
    switch (method?.toUpperCase()) {
      case 'QRIS':
        return PaymentMethod.qris;
      case 'TRANSFER':
        return PaymentMethod.transfer;
      case 'CUSTOMER_WALLET':
        return PaymentMethod.yeloWallet;
      default:
        return PaymentMethod.cash;
    }
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}
