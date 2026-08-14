import 'package:yelo_laundry_customer/core/network/api_client.dart';

class SupportTicketSummary {
  const SupportTicketSummary({
    required this.id,
    required this.category,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  final String id;
  final String category;
  final String subject;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? lastMessage;

  factory SupportTicketSummary.fromJson(Map<String, dynamic> json) {
    return SupportTicketSummary(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'LAINNYA',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      lastMessage: json['lastMessage'] as String?,
    );
  }
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String senderType;
  final String message;
  final String createdAt;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String,
      senderType: json['senderType'] as String? ?? 'CUSTOMER',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class SupportTicketDetail {
  const SupportTicketDetail({
    required this.id,
    required this.category,
    required this.subject,
    required this.status,
    required this.messages,
  });

  final String id;
  final String category;
  final String subject;
  final String status;
  final List<SupportMessage> messages;

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List<dynamic>? ?? const [])
        .map((item) => SupportMessage.fromJson(item as Map<String, dynamic>))
        .toList();

    return SupportTicketDetail(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'LAINNYA',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      messages: messages,
    );
  }
}

class SupportRepository {
  SupportRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<SupportTicketSummary>> fetchTickets() async {
    final data = await _api.get<List<dynamic>>(
      '/customer-app/support/tickets',
      parser: (json) => json as List<dynamic>,
    );

    return data
        .map((item) => SupportTicketSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SupportTicketDetail> createTicket({
    required String category,
    required String subject,
    required String message,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/customer-app/support/tickets',
      data: {
        'category': category,
        'subject': subject,
        'message': message,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return SupportTicketDetail.fromJson(data);
  }

  Future<SupportTicketDetail> fetchTicket(String ticketId) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/support/tickets/$ticketId',
      parser: (json) => json as Map<String, dynamic>,
    );

    return SupportTicketDetail.fromJson(data);
  }

  Future<SupportTicketDetail> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/customer-app/support/tickets/$ticketId/messages',
      data: {'message': message},
      parser: (json) => json as Map<String, dynamic>,
    );

    return SupportTicketDetail.fromJson(data);
  }
}
