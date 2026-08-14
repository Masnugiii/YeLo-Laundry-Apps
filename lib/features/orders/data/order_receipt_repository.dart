import 'package:yelo_laundry_erp/core/network/api_client.dart';

class OrderReceiptDelivery {
  const OrderReceiptDelivery({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.messageText,
    required this.paymentStatus,
    required this.paymentMethodLabel,
    required this.deliveryStatus,
    required this.deliveryChannel,
    required this.providerAvailable,
    required this.sentAt,
    required this.failureReason,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final String messageText;
  final String paymentStatus;
  final String paymentMethodLabel;
  final String deliveryStatus;
  final String deliveryChannel;
  final bool providerAvailable;
  final String? sentAt;
  final String? failureReason;
  final String createdAt;

  bool get isSent => deliveryStatus == 'SENT';
  bool get isNotConfigured => deliveryStatus == 'NOT_CONFIGURED';
  bool get isFailed => deliveryStatus == 'FAILED';
  bool get isPending => deliveryStatus == 'PENDING';

  factory OrderReceiptDelivery.fromJson(Map<String, dynamic> json) {
    return OrderReceiptDelivery(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String?,
      messageText: json['messageText'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      paymentMethodLabel: json['paymentMethodLabel'] as String? ?? '-',
      deliveryStatus: json['deliveryStatus'] as String? ?? 'PENDING',
      deliveryChannel: json['deliveryChannel'] as String? ?? 'WHATSAPP',
      providerAvailable: json['providerAvailable'] as bool? ?? false,
      sentAt: json['sentAt'] as String?,
      failureReason: json['failureReason'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class OrderReceiptRepository {
  OrderReceiptRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<OrderReceiptDelivery> generateReceipt(String orderId) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/orders/$orderId/receipts/whatsapp/generate',
      parser: (json) => json as Map<String, dynamic>,
    );
    return OrderReceiptDelivery.fromJson(data);
  }

  Future<OrderReceiptDelivery> sendReceipt({
    required String orderId,
    required String receiptId,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/orders/$orderId/receipts/whatsapp/$receiptId/send',
      parser: (json) => json as Map<String, dynamic>,
    );
    return OrderReceiptDelivery.fromJson(data);
  }

  Future<OrderReceiptDelivery> recordHandoff({
    required String orderId,
    required String receiptId,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/orders/$orderId/receipts/whatsapp/$receiptId/handoff',
      parser: (json) => json as Map<String, dynamic>,
    );
    return OrderReceiptDelivery.fromJson(data);
  }

  Future<List<OrderReceiptDelivery>> listDeliveries(String orderId) async {
    final data = await _apiClient.get<List<dynamic>>(
      '/orders/$orderId/receipts',
      parser: (json) => json as List<dynamic>,
    );
    return data
        .map((item) => OrderReceiptDelivery.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
