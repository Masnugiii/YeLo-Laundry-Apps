import 'package:yelo_laundry_customer/core/network/api_client.dart';

class DashboardData {
  const DashboardData({
    required this.greetingName,
    required this.activeOrders,
    required this.readyPickup,
    required this.walletBalance,
    required this.rewardPoints,
    required this.unreadNotifications,
    required this.latestNotifications,
  });

  final String greetingName;
  final int activeOrders;
  final int readyPickup;
  final double walletBalance;
  final int rewardPoints;
  final int unreadNotifications;
  final List<NotificationPreview> latestNotifications;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      greetingName: json['greetingName'] as String,
      activeOrders: json['activeOrders'] as int,
      readyPickup: json['readyPickup'] as int,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      rewardPoints: json['rewardPoints'] as int,
      unreadNotifications: json['unreadNotifications'] as int,
      latestNotifications: (json['latestNotifications'] as List<dynamic>)
          .map((e) => NotificationPreview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationPreview {
  const NotificationPreview({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  factory NotificationPreview.fromJson(Map<String, dynamic> json) {
    return NotificationPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<DashboardData> getDashboard() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/dashboard',
      parser: (json) => json as Map<String, dynamic>,
    );
    return DashboardData.fromJson(data);
  }
}
