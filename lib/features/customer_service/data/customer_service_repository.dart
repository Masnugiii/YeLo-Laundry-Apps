import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';

class CustomerServiceRepository {
  CustomerServiceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CustomerServiceSummary> fetchSummary() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customer-service/summary',
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerServiceSummary(
      unreadMessages: (data['unreadMessages'] as num?)?.toInt() ?? 0,
      newComplaints: (data['newComplaints'] as num?)?.toInt() ?? 0,
      orderQuestions: (data['orderQuestions'] as num?)?.toInt() ?? 0,
      completed: (data['completed'] as num?)?.toInt() ?? 0,
    );
  }

  Future<PaginatedResponse<WhatsappConversation>> fetchTickets({
    int page = 1,
    int limit = 50,
    String? search,
    String? category,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customer-service/tickets',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapListItem(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<WhatsappConversation> fetchTicketDetail(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customer-service/tickets/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapDetail(data);
  }

  Future<WhatsappConversation> updateTicketCategory({
    required String id,
    required WhatsappMessageCategory category,
  }) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/customer-service/tickets/$id',
      data: {'category': _categoryToApi(category)},
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapDetail(data);
  }

  Future<WhatsappConversation> sendReply({
    required String id,
    required String message,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/customer-service/tickets/$id/messages',
      data: {'message': message},
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapDetail(data);
  }

  WhatsappConversation _mapListItem(Map<String, dynamic> json) {
    return WhatsappConversation(
      id: json['id'] as String,
      customerName: json['customerName'] as String? ?? '-',
      whatsappNumber: json['whatsappNumber'] as String? ?? '-',
      messagePreview: json['messagePreview'] as String? ?? '',
      messageTime: DateTime.tryParse(json['messageTime'] as String? ?? '') ??
          DateTime.now(),
      aiCategory: _categoryFromApi(json['category'] as String?),
      aiConfidence: (json['aiConfidence'] as num?)?.toInt() ?? 0,
      isUnread: json['isUnread'] as bool? ?? false,
      aiSummary: '',
      messages: const [],
    );
  }

  WhatsappConversation _mapDetail(Map<String, dynamic> json) {
    final relatedOrderJson = json['relatedOrder'] as Map<String, dynamic>?;
    final messages = (json['messages'] as List<dynamic>? ?? const [])
        .map(
          (item) => _mapMessage(item as Map<String, dynamic>),
        )
        .toList();

    return WhatsappConversation(
      id: json['id'] as String,
      customerName: json['customerName'] as String? ?? '-',
      whatsappNumber: json['whatsappNumber'] as String? ?? '-',
      messagePreview: json['messagePreview'] as String? ?? '',
      messageTime: DateTime.tryParse(json['messageTime'] as String? ?? '') ??
          DateTime.now(),
      aiCategory: _categoryFromApi(json['category'] as String?),
      aiConfidence: (json['aiConfidence'] as num?)?.toInt() ?? 0,
      isUnread: json['isUnread'] as bool? ?? false,
      aiSummary: json['aiSummary'] as String? ?? '',
      relatedOrder: relatedOrderJson == null
          ? null
          : RelatedOrderInfo(
              queueNumber: relatedOrderJson['queueNumber'] as String? ?? '-',
              laundryService:
                  relatedOrderJson['laundryService'] as String? ?? '-',
              currentStatus:
                  relatedOrderJson['currentStatus'] as String? ?? '-',
              estimatedCompletion: DateTime.tryParse(
                    relatedOrderJson['estimatedCompletion'] as String? ?? '',
                  ) ??
                  DateTime.now(),
            ),
      messages: messages,
    );
  }

  WhatsappChatMessage _mapMessage(Map<String, dynamic> json) {
    return WhatsappChatMessage(
      id: json['id'] as String,
      isFromCustomer: json['isFromCustomer'] as bool? ?? false,
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  WhatsappMessageCategory _categoryFromApi(String? value) {
    return switch (value) {
      'ORDER_BARU' => WhatsappMessageCategory.orderBaru,
      'KOMPLAIN' => WhatsappMessageCategory.komplain,
      'PERTANYAAN' => WhatsappMessageCategory.pertanyaan,
      'PROMO' => WhatsappMessageCategory.promo,
      'TRACKING_ORDER' => WhatsappMessageCategory.trackingOrder,
      _ => WhatsappMessageCategory.lainnya,
    };
  }

  String _categoryToApi(WhatsappMessageCategory category) {
    return switch (category) {
      WhatsappMessageCategory.orderBaru => 'ORDER_BARU',
      WhatsappMessageCategory.komplain => 'KOMPLAIN',
      WhatsappMessageCategory.pertanyaan => 'PERTANYAAN',
      WhatsappMessageCategory.promo => 'PROMO',
      WhatsappMessageCategory.trackingOrder => 'TRACKING_ORDER',
      WhatsappMessageCategory.lainnya => 'LAINNYA',
    };
  }
}

List<WhatsappConversation> filterWhatsappConversations({
  required List<WhatsappConversation> conversations,
  required String query,
  required WhatsappConversationFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return conversations.where((conversation) {
    final matchesFilter = switch (filter) {
      WhatsappConversationFilter.semua => true,
      WhatsappConversationFilter.orderBaru =>
        conversation.aiCategory == WhatsappMessageCategory.orderBaru,
      WhatsappConversationFilter.komplain =>
        conversation.aiCategory == WhatsappMessageCategory.komplain,
      WhatsappConversationFilter.pertanyaan =>
        conversation.aiCategory == WhatsappMessageCategory.pertanyaan ||
            conversation.aiCategory == WhatsappMessageCategory.trackingOrder,
      WhatsappConversationFilter.promo =>
        conversation.aiCategory == WhatsappMessageCategory.promo,
      WhatsappConversationFilter.lainnya =>
        conversation.aiCategory == WhatsappMessageCategory.lainnya,
    };

    if (!matchesFilter) return false;

    if (normalizedQuery.isEmpty) return true;

    return conversation.customerName.toLowerCase().contains(normalizedQuery) ||
        conversation.whatsappNumber.toLowerCase().contains(normalizedQuery);
  }).toList();
}

String? filterToApiCategory(WhatsappConversationFilter filter) {
  return switch (filter) {
    WhatsappConversationFilter.orderBaru => 'ORDER_BARU',
    WhatsappConversationFilter.komplain => 'KOMPLAIN',
    WhatsappConversationFilter.promo => 'PROMO',
    WhatsappConversationFilter.lainnya => 'LAINNYA',
    WhatsappConversationFilter.semua ||
    WhatsappConversationFilter.pertanyaan =>
      null,
  };
}
