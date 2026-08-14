int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
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
    this.metadata,
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
  final Map<String, dynamic>? metadata;

  bool get isLaundryKg => type == RewardCatalogType.laundryKg;
  int? get entitlementKg => kg;
  int? get durationDays => serviceDurationDays;

  factory RewardCatalogItem.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : null;
    return RewardCatalogItem(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: rewardCatalogTypeFromApi(json['type'] as String?),
      costPoints: _asInt(json['costPoints']) ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      kg: _asInt(json['entitlementKg']) ??
          _asInt(json['kg']) ??
          _asInt(metadata?['freeKg']),
      serviceType: json['serviceType'] as String? ??
          metadata?['serviceType'] as String?,
      serviceDurationDays: _asInt(json['durationDays']) ??
          _asInt(json['serviceDurationDays']) ??
          _asInt(metadata?['durationDays']),
      stock: _asInt(json['stock']),
      pointRewardValueIdr: _asInt(json['pointRewardValueIdr']),
      metadata: metadata,
    );
  }
}

int pointsNeeded(int costPoints, int currentPoints) {
  final needed = costPoints - currentPoints;
  return needed > 0 ? needed : 0;
}

class YeloRewardsSummary {
  const YeloRewardsSummary({
    required this.currentPoint,
    required this.earned,
    required this.redeemed,
    required this.expired,
    required this.clawback,
    required this.activeEntitlements,
    required this.redemptions,
    this.membershipLevelCode,
    this.membershipLevelName,
    this.lifetimePoints,
    this.progressPercent,
    this.pointsToNext,
  });

  final int currentPoint;
  final int earned;
  final int redeemed;
  final int expired;
  final int clawback;
  final List<CksEntitlement> activeEntitlements;
  final List<RewardRedemptionSummary> redemptions;
  final String? membershipLevelCode;
  final String? membershipLevelName;
  final int? lifetimePoints;
  final int? progressPercent;
  final int? pointsToNext;

  List<CksEntitlement> get cksCustomerEntitlements {
    final fromRedemptions = <CksEntitlement>[];
    for (final redemption in redemptions) {
      for (final item in redemption.items) {
        if (!item.isLaundryKg) continue;
        fromRedemptions.add(
          CksEntitlement(
            redemptionItemId: item.id,
            rewardName: item.rewardName,
            rewardCode: item.rewardCode,
            pointsSpent: item.pointsSpent,
            entitlementKg: item.entitlementKg ?? 0,
            remainingKg: item.remainingKg ?? 0,
            entitlementStatus: item.entitlementStatus ?? 'AVAILABLE',
            expiresAt: item.entitlementExpiresAt,
            redeemedAt: redemption.createdAt,
          ),
        );
      }
    }
    if (fromRedemptions.isNotEmpty) return fromRedemptions;
    return activeEntitlements;
  }
}

class CksEntitlement {
  const CksEntitlement({
    required this.redemptionItemId,
    required this.rewardName,
    required this.rewardCode,
    required this.pointsSpent,
    required this.entitlementKg,
    required this.remainingKg,
    required this.entitlementStatus,
    required this.expiresAt,
    this.redeemedAt,
  });

  final String redemptionItemId;
  final String rewardName;
  final String rewardCode;
  final int pointsSpent;
  final double entitlementKg;
  final double remainingKg;
  final String entitlementStatus;
  final DateTime? expiresAt;
  final DateTime? redeemedAt;

  bool get isUsable =>
      remainingKg > 0 &&
      (entitlementStatus == 'AVAILABLE' ||
          entitlementStatus == 'PARTIALLY_USED');
}

class RewardRedemptionSummary {
  const RewardRedemptionSummary({
    required this.id,
    required this.status,
    required this.totalPointsSpent,
    required this.createdAt,
    required this.items,
    this.fulfilledAt,
  });

  final String id;
  final String status;
  final int totalPointsSpent;
  final DateTime createdAt;
  final DateTime? fulfilledAt;
  final List<RewardRedemptionItemSummary> items;

  bool get isPhysicalPending =>
      status == 'PENDING' &&
      items.any((item) => item.rewardType == 'PHYSICAL_GOODS');
}

class RewardRedemptionItemSummary {
  const RewardRedemptionItemSummary({
    required this.id,
    required this.rewardName,
    required this.rewardCode,
    required this.rewardType,
    required this.pointsSpent,
    this.entitlementKg,
    this.remainingKg,
    this.entitlementStatus,
    this.entitlementExpiresAt,
  });

  final String id;
  final String rewardName;
  final String rewardCode;
  final String rewardType;
  final int pointsSpent;
  final double? entitlementKg;
  final double? remainingKg;
  final String? entitlementStatus;
  final DateTime? entitlementExpiresAt;

  bool get isPhysical => rewardType == 'PHYSICAL_GOODS';
  bool get isLaundryKg => rewardType == 'LAUNDRY_KG';
}

class CksEntitlementPreview {
  const CksEntitlementPreview({
    required this.redemptionItemId,
    required this.orderKg,
    required this.freeKg,
    required this.billableKg,
    required this.remainingKgAfter,
  });

  final String redemptionItemId;
  final double orderKg;
  final double freeKg;
  final double billableKg;
  final double remainingKgAfter;
}
