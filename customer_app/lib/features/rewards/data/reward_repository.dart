import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';

class RewardSummary {
  const RewardSummary({
    required this.currentPoints,
    required this.expiredPoints,
  });

  final int currentPoints;
  final int expiredPoints;

  factory RewardSummary.fromJson(Map<String, dynamic> json) {
    return RewardSummary(
      currentPoints: json['currentPoints'] as int,
      expiredPoints: json['expiredPoints'] as int,
    );
  }
}

class RewardHistoryItem {
  const RewardHistoryItem({
    required this.id,
    required this.point,
    required this.type,
    required this.createdAt,
    this.description,
    this.expiredAt,
  });

  final String id;
  final int point;
  final String type;
  final String createdAt;
  final String? description;
  final String? expiredAt;

  factory RewardHistoryItem.fromJson(Map<String, dynamic> json) {
    return RewardHistoryItem(
      id: json['id'] as String,
      point: json['point'] as int,
      type: json['type'] as String,
      createdAt: json['createdAt'] as String,
      description: json['description'] as String?,
      expiredAt: json['expiredAt'] as String?,
    );
  }
}

class RewardRepository {
  RewardRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<RewardSummary> getSummary() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/rewards',
      parser: (json) => json as Map<String, dynamic>,
    );
    return RewardSummary.fromJson(data);
  }

  Future<PaginatedResponse<RewardHistoryItem>> getHistory({int page = 1}) async {
    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      '/customer-app/rewards/history',
      queryParameters: {'page': page, 'limit': AppConfig.defaultPageSize},
      parser: (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data!;
    return PaginatedResponse<RewardHistoryItem>(
      items: (data['items'] as List<dynamic>)
          .map((e) => RewardHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>),
    );
  }
}
