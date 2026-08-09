import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedResponse<Map<String, dynamic>>> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (isRead != null) 'isRead': isRead,
        if (type != null) 'type': type,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<int> fetchUnreadCount() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/notifications/unread-count',
      parser: (json) => json as Map<String, dynamic>,
    );
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) async {
    await _apiClient.post<void>('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.post<void>('/notifications/read-all');
  }
}
