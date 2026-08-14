import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/features/points/models/point_transaction.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';

class LoyaltyRepository {
  LoyaltyRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<int> fetchCurrentPoints(String customerId) async {
    final summary = await fetchYeloRewardsSummary(customerId);
    return summary.currentPoint;
  }

  Future<YeloRewardsSummary> fetchYeloRewardsSummary(String customerId) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$customerId/loyalty',
      parser: (json) => json as Map<String, dynamic>,
    );

    final yelo = data['yeloRewards'] as Map<String, dynamic>? ??
        data['rewardPoint'] as Map<String, dynamic>? ??
        const {};

    final entitlementsRaw =
        data['activeCksEntitlements'] as List<dynamic>? ?? const [];
    final redemptionsRaw =
        data['rewardRedemptions'] as List<dynamic>? ?? const [];
    final membership = data['membership'] as Map<String, dynamic>?;
    final currentLevel = membership?['currentLevel'] as Map<String, dynamic>?;

    return YeloRewardsSummary(
      currentPoint: (yelo['currentPoint'] as num?)?.toInt() ?? 0,
      earned: (yelo['earned'] as num?)?.toInt() ?? 0,
      redeemed: (yelo['redeemed'] as num?)?.toInt() ??
          (yelo['used'] as num?)?.toInt() ??
          0,
      expired: (yelo['expired'] as num?)?.toInt() ?? 0,
      clawback: (yelo['clawback'] as num?)?.toInt() ?? 0,
      activeEntitlements: entitlementsRaw
          .map((item) => _mapEntitlement(item as Map<String, dynamic>))
          .toList(),
      redemptions: redemptionsRaw
          .map((item) => _mapRedemption(item as Map<String, dynamic>))
          .toList(),
      membershipLevelCode: currentLevel?['code'] as String?,
      membershipLevelName: currentLevel?['name'] as String?,
      lifetimePoints: (membership?['lifetimePoints'] as num?)?.toInt(),
      progressPercent: (membership?['progressPercent'] as num?)?.toInt(),
      pointsToNext: (membership?['pointsToNext'] as num?)?.toInt(),
    );
  }

  Future<List<CksEntitlement>> fetchActiveCksEntitlements(
    String customerId,
  ) async {
    final data = await _apiClient.get<List<dynamic>>(
      '/customers/$customerId/loyalty/entitlements',
      parser: (json) => json as List<dynamic>,
    );
    return data
        .map((item) => _mapEntitlement(item as Map<String, dynamic>))
        .toList();
  }

  Future<CksEntitlementPreview> previewCksEntitlement({
    required String customerId,
    required String redemptionItemId,
    required double orderKg,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/customers/$customerId/loyalty/entitlements/preview',
      data: {
        'redemptionItemId': redemptionItemId,
        'orderKg': orderKg,
        'serviceType': 'CKS',
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return CksEntitlementPreview(
      redemptionItemId: data['redemptionItemId'] as String? ?? redemptionItemId,
      orderKg: (data['orderKg'] as num?)?.toDouble() ?? orderKg,
      freeKg: (data['freeKg'] as num?)?.toDouble() ?? 0,
      billableKg: (data['billableKg'] as num?)?.toDouble() ?? orderKg,
      remainingKgAfter: (data['remainingKgAfter'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> fulfillPhysicalRedemption(String redemptionId) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/reward/redemptions/$redemptionId/fulfill',
      data: const {},
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<RewardCatalogItem>> fetchRewardCatalog({
    String? customerId,
  }) async {
    if (customerId != null && customerId.isNotEmpty) {
      try {
        final data = await _apiClient.get<List<dynamic>>(
          '/customers/$customerId/loyalty/catalog',
          parser: (json) => json as List<dynamic>,
        );
        return data
            .map((item) => RewardCatalogItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fall through to the shared loyalty catalog endpoint.
      }
    }

    final data = await _apiClient.get<List<dynamic>>(
      '/loyalty/rewards/catalog',
      queryParameters: const {'includeInactive': false},
      parser: (json) => json as List<dynamic>,
    );
    return data
        .map((item) => RewardCatalogItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PointTransaction>> fetchPointHistory({
    required String customerId,
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/customers/$customerId/loyalty/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = data['items'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              _mapPointTransaction(customerId, item as Map<String, dynamic>),
        )
        .toList();
  }

  CksEntitlement _mapEntitlement(Map<String, dynamic> json) {
    return CksEntitlement(
      redemptionItemId: json['redemptionItemId'] as String? ??
          json['id'] as String? ??
          '',
      rewardName: json['rewardName'] as String? ?? 'CKS',
      rewardCode: json['rewardCode'] as String? ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      entitlementKg: (json['entitlementKg'] as num?)?.toDouble() ?? 0,
      remainingKg: (json['remainingKg'] as num?)?.toDouble() ?? 0,
      entitlementStatus: json['entitlementStatus'] as String? ?? 'AVAILABLE',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      redeemedAt: DateTime.tryParse(json['redeemedAt'] as String? ?? ''),
    );
  }

  RewardRedemptionSummary _mapRedemption(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapRedemptionItem(item as Map<String, dynamic>))
        .toList();

    return RewardRedemptionSummary(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      totalPointsSpent: (json['totalPointsSpent'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      fulfilledAt: DateTime.tryParse(json['fulfilledAt'] as String? ?? ''),
      items: items,
    );
  }

  RewardRedemptionItemSummary _mapRedemptionItem(Map<String, dynamic> json) {
    return RewardRedemptionItemSummary(
      id: json['id'] as String? ?? '',
      rewardName: json['rewardName'] as String? ?? '',
      rewardCode: json['rewardCode'] as String? ?? '',
      rewardType: json['rewardType'] as String? ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      entitlementKg: (json['entitlementKg'] as num?)?.toDouble(),
      remainingKg: (json['remainingKg'] as num?)?.toDouble(),
      entitlementStatus: json['entitlementStatus'] as String?,
      entitlementExpiresAt:
          DateTime.tryParse(json['entitlementExpiresAt'] as String? ?? ''),
    );
  }

  PointTransaction _mapPointTransaction(
    String customerId,
    Map<String, dynamic> json,
  ) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    final activity = (json['activity'] as String? ?? '').toLowerCase();
    final activityLabel = json['activityLabel'] as String?;
    final description = activityLabel ??
        json['description'] as String? ??
        activity;
    final reference = json['reference'] as String? ??
        json['referenceType'] as String? ??
        '-';

    return PointTransaction(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? customerId,
      date: createdAt,
      points: (json['point'] as num?)?.toInt() ?? 0,
      source: _mapPointSource(activity, description),
      referenceNumber: reference,
      description: description,
    );
  }

  PointSource _mapPointSource(String activity, String description) {
    final text = '$activity $description'.toLowerCase();
    if (text.contains('laundry') || text.contains('pembayaran laundry')) {
      return PointSource.orderLaundry;
    }
    if (text.contains('deposit') || text.contains('wallet') || text.contains('top')) {
      return PointSource.topUpDompet;
    }
    if (text.contains('redeem') || text.contains('penukaran')) {
      return PointSource.manualAdjustment;
    }
    if (text.contains('expired') || text.contains('kedaluwarsa')) {
      return PointSource.manualAdjustment;
    }
    if (text.contains('clawback') || text.contains('pembatalan')) {
      return PointSource.manualAdjustment;
    }
    if (text.contains('promo') || text.contains('voucher')) {
      return PointSource.promoMember;
    }
    if (text.contains('birthday') || text.contains('ulang')) {
      return PointSource.bonusUlangTahun;
    }
    if (text.contains('referral')) {
      return PointSource.referral;
    }
    return PointSource.manualAdjustment;
  }
}
