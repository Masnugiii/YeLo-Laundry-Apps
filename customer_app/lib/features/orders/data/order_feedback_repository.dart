import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';

class OrderFeedbackMessage {
  const OrderFeedbackMessage({
    required this.id,
    required this.senderType,
    required this.senderLabel,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String senderType;
  final String senderLabel;
  final String message;
  final String createdAt;

  bool get isFromCustomer => senderType.toUpperCase() == 'CUSTOMER';

  factory OrderFeedbackMessage.fromJson(Map<String, dynamic> json) {
    return OrderFeedbackMessage(
      id: json['id'] as String,
      senderType: json['senderType'] as String,
      senderLabel: json['senderLabel'] as String,
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class OrderFeedback {
  const OrderFeedback({
    required this.orderId,
    required this.ticketId,
    required this.status,
    required this.messages,
  });

  final String orderId;
  final String? ticketId;
  final String? status;
  final List<OrderFeedbackMessage> messages;

  factory OrderFeedback.fromJson(Map<String, dynamic> json) {
    return OrderFeedback(
      orderId: json['orderId'] as String,
      ticketId: json['ticketId'] as String?,
      status: json['status'] as String?,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((item) => OrderFeedbackMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderFeedbackRepository {
  OrderFeedbackRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<OrderFeedback> getFeedback(String orderId) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.orderFeedback(orderId);
    }

    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/orders/$orderId/feedback',
      parser: (json) => json as Map<String, dynamic>,
    );

    return OrderFeedback.fromJson(data);
  }

  Future<OrderFeedback> sendFeedback({
    required String orderId,
    required String message,
  }) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.sendOrderFeedback(orderId, message);
    }

    final data = await _api.post<Map<String, dynamic>>(
      '/customer-app/orders/$orderId/feedback',
      data: {'message': message},
      parser: (json) => json as Map<String, dynamic>,
    );

    return OrderFeedback.fromJson(data);
  }
}
