import 'dart:math';

import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
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
      currentPoints: _asInt(json['currentPoints']),
      expiredPoints: _asInt(json['expiredPoints']),
    );
  }
}

enum RewardCatalogType {
  laundryKg,
  physicalGoods,
  unknown,
}

RewardCatalogType rewardCatalogTypeFromApi(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'LAUNDRY_KG':
      return RewardCatalogType.laundryKg;
    case 'PHYSICAL_GOODS':
      return RewardCatalogType.physicalGoods;
    default:
      return RewardCatalogType.unknown;
  }
}

class RewardCatalogItem {
  const RewardCatalogItem({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.costPoints,
    required this.isActive,
    this.description,
    this.kg,
    this.serviceType,
    this.serviceDurationDays,
    this.stock,
    this.pointRewardValueIdr,
  });

  final String id;
  final String code;
  final String name;
  final RewardCatalogType type;
  final int costPoints;
  final bool isActive;
  final String? description;
  final int? kg;
  final String? serviceType;
  final int? serviceDurationDays;
  final int? stock;
  final int? pointRewardValueIdr;

  bool get isLaundryKg => type == RewardCatalogType.laundryKg;

  factory RewardCatalogItem.fromJson(Map<String, dynamic> json) {
    return RewardCatalogItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: rewardCatalogTypeFromApi(json['type'] as String?),
      costPoints: _asInt(json['costPoints']),
      isActive: json['isActive'] as bool? ?? true,
      kg: json['kg'] == null ? null : _asInt(json['kg']),
      serviceType: json['serviceType'] as String?,
      serviceDurationDays: json['serviceDurationDays'] == null
          ? null
          : _asInt(json['serviceDurationDays']),
      stock: json['stock'] == null ? null : _asInt(json['stock']),
      pointRewardValueIdr: json['pointRewardValueIdr'] == null
          ? null
          : _asInt(json['pointRewardValueIdr']),
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
    this.source,
  });

  final String id;
  final int point;
  final String type;
  final String createdAt;
  final String? description;
  final String? expiredAt;
  final String? source;

  factory RewardHistoryItem.fromJson(Map<String, dynamic> json) {
    return RewardHistoryItem(
      id: json['id'] as String,
      point: _asInt(json['point']),
      type: json['type'] as String,
      createdAt: json['createdAt'] as String,
      description: json['description'] as String?,
      expiredAt: json['expiredAt'] as String?,
      source: json['source'] as String?,
    );
  }
}

class RewardRedemptionItem {
  const RewardRedemptionItem({
    required this.id,
    required this.catalogItemId,
    required this.quantity,
    required this.pointsSpent,
    required this.rewardName,
    required this.rewardType,
    this.entitlementKg,
    this.serviceDurationDays,
    this.serviceType,
  });

  final String id;
  final String catalogItemId;
  final int quantity;
  final int pointsSpent;
  final String rewardName;
  final RewardCatalogType rewardType;
  final int? entitlementKg;
  final int? serviceDurationDays;
  final String? serviceType;

  factory RewardRedemptionItem.fromJson(Map<String, dynamic> json) {
    final reward = json['reward'] as Map<String, dynamic>? ?? const {};
    final metadata = json['metadata'] as Map<String, dynamic>?;
    return RewardRedemptionItem(
      id: json['id'] as String,
      catalogItemId: json['catalogItemId'] as String,
      quantity: _asInt(json['quantity']),
      pointsSpent: _asInt(json['pointsSpent']),
      rewardName: (reward['name'] as String?) ?? 'Reward',
      rewardType: rewardCatalogTypeFromApi(reward['type'] as String?),
      entitlementKg: json['entitlementKg'] == null
          ? null
          : _asInt(json['entitlementKg']),
      serviceDurationDays: reward['serviceDurationDays'] == null
          ? (metadata?['durationDays'] == null
                ? null
                : _asInt(metadata!['durationDays']))
          : _asInt(reward['serviceDurationDays']),
      serviceType:
          (reward['serviceType'] as String?) ??
          (metadata?['serviceType'] as String?),
    );
  }
}

class RewardRedemption {
  const RewardRedemption({
    required this.id,
    required this.status,
    required this.totalPointsSpent,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String status;
  final int totalPointsSpent;
  final String createdAt;
  final List<RewardRedemptionItem> items;

  String get primaryRewardName =>
      items.isEmpty ? 'Reward' : items.first.rewardName;

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: json['id'] as String,
      status: json['status'] as String,
      totalPointsSpent: _asInt(json['totalPointsSpent']),
      createdAt: json['createdAt'] as String,
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => RewardRedemptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RedeemRewardResult {
  const RedeemRewardResult({
    required this.redemption,
    required this.availablePoints,
  });

  final RewardRedemption redemption;
  final int availablePoints;

  factory RedeemRewardResult.fromJson(Map<String, dynamic> json) {
    return RedeemRewardResult(
      redemption: RewardRedemption.fromJson(
        json['redemption'] as Map<String, dynamic>,
      ),
      availablePoints: _asInt(json['availablePoints']),
    );
  }
}

class RedeemRewardItemRequest {
  const RedeemRewardItemRequest({
    required this.catalogItemId,
    this.quantity = 1,
  });

  final String catalogItemId;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'catalogItemId': catalogItemId,
    'quantity': quantity,
  };
}

String createRedeemIdempotencyKey() {
  final random = Random.secure();
  String chunk(int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(random.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }

  return '${chunk(8)}-${chunk(4)}-4${chunk(3)}-'
      '${(8 + random.nextInt(4)).toRadixString(16)}${chunk(3)}-${chunk(12)}';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class RewardRepository {
  RewardRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<RewardSummary> getSummary() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.rewardSummary;
    }

    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/rewards',
      parser: (json) => json as Map<String, dynamic>,
    );
    return RewardSummary.fromJson(data);
  }

  Future<List<RewardCatalogItem>> getCatalog() async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.rewardCatalog;
    }

    final data = await _api.get<List<dynamic>>(
      '/customer-app/rewards/catalog',
      parser: (json) => json as List<dynamic>,
    );
    return data
        .map((e) => RewardCatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RewardCatalogItem> getCatalogDetail(String catalogItemId) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.rewardCatalogDetail(catalogItemId);
    }

    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/rewards/catalog/$catalogItemId',
      parser: (json) => json as Map<String, dynamic>,
    );
    return RewardCatalogItem.fromJson(data);
  }

  Future<RedeemRewardResult> redeem({
    required List<RedeemRewardItemRequest> items,
    String? idempotencyKey,
  }) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.redeemRewards(
        items: items,
        idempotencyKey: idempotencyKey ?? createRedeemIdempotencyKey(),
      );
    }

    final data = await _api.post<Map<String, dynamic>>(
      '/customer-app/rewards/redeem',
      data: {
        'items': items.map((item) => item.toJson()).toList(),
        'idempotencyKey': ?idempotencyKey,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return RedeemRewardResult.fromJson(data);
  }

  Future<PaginatedResponse<RewardRedemption>> getRedemptions({
    int page = 1,
  }) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.paginatedRewardRedemptions;
    }

    final envelope = await _api.getEnvelope<Map<String, dynamic>>(
      '/customer-app/rewards/redemptions',
      queryParameters: {'page': page, 'limit': AppConfig.defaultPageSize},
      parser: (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data!;
    return PaginatedResponse<RewardRedemption>(
      items: (data['items'] as List<dynamic>)
          .map((e) => RewardRedemption.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>),
    );
  }

  Future<PaginatedResponse<RewardHistoryItem>> getHistory({int page = 1}) async {
    if (DevPreviewGate.isActive) {
      return DevPreviewData.paginatedRewardHistory;
    }

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
