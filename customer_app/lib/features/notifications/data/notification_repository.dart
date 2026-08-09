import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.priority,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final String createdAt;
  final bool isRead;
  final String? priority;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool? ?? false,
      priority: json['priority'] as String?,
    );
  }
}

class NotificationRepository {
  NotificationRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
    bool? unreadOnly,
  }) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': AppConfig.defaultPageSize,
        if (unreadOnly == true) 'isRead': false,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data!;
    return PaginatedResponse<AppNotification>(
      items: (data['items'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>),
    );
  }

  Future<AppNotification> getDetail(String id) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/notifications/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return AppNotification.fromJson(data);
  }

  Future<int> getUnreadCount() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/notifications/unread-count',
      parser: (json) => json as Map<String, dynamic>,
    );
    return data['count'] as int;
  }

  Future<void> markRead(String id) async {
    await _api.post<void>('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.post<void>('/notifications/read-all');
  }

  Future<void> delete(String id) async {
    await _api.delete<void>('/notifications/$id');
  }
}
