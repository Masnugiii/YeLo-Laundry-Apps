import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/utils/reward_labels.dart';

void main() {
  setUp(() {
    DevPreviewData.resetRewardsPreviewForTests();
  });

  test('preview catalog has six YeLo Rewards and no old missions', () {
    expect(DevPreviewData.rewardCatalog.length, 6);
    expect(
      DevPreviewData.rewardCatalog.map((item) => item.code).toList(),
      containsAll([
        'CKS_5KG',
        'CKS_10KG',
        'BANTAL_PREMIUM',
        'BLENDER',
        'SPREI',
        'MAGIC_COM',
      ]),
    );
    expect(
      DevPreviewData.rewardCatalog.any((item) => item.name.contains('Quiz')),
      isFalse,
    );
    expect(DevPreviewData.rewardSummary.currentPoints, 8);
  });

  test('preview balance unlocks 5pt rewards and locks 10/15pt rewards', () {
    const points = 8;
    final available = DevPreviewData.rewardCatalog
        .where((item) => pointsNeeded(item.costPoints, points) == 0)
        .map((item) => item.code)
        .toList();
    final locked = DevPreviewData.rewardCatalog
        .where((item) => pointsNeeded(item.costPoints, points) > 0)
        .map((item) => item.code)
        .toList();

    expect(available, containsAll(['CKS_5KG', 'BANTAL_PREMIUM']));
    expect(locked, containsAll(['CKS_10KG', 'BLENDER', 'SPREI', 'MAGIC_COM']));
    expect(pointsNeeded(10, 8), 2);
    expect(pointsNeeded(15, 8), 7);
  });

  test('preview CKS metadata stores kg entitlement and duration', () {
    final cks5 = DevPreviewData.rewardCatalog.firstWhere(
      (item) => item.code == 'CKS_5KG',
    );
    final cks10 = DevPreviewData.rewardCatalog.firstWhere(
      (item) => item.code == 'CKS_10KG',
    );

    expect(cks5.kg, 5);
    expect(cks5.serviceDurationDays, 3);
    expect(cks5.serviceType, 'CKS');
    expect(cks10.kg, 10);
    expect(cks10.serviceDurationDays, 3);
  });

  test('preview redeem updates available points', () {
    final before = DevPreviewData.rewardSummary.currentPoints;
    final result = DevPreviewData.redeemRewards(
      items: [
        const RedeemRewardItemRequest(catalogItemId: 'dev-reward-bantal'),
      ],
      idempotencyKey: '11111111-1111-1111-1111-111111111111',
    );

    expect(result.redemption.totalPointsSpent, 5);
    expect(result.availablePoints, before - 5);
    expect(result.redemption.status, 'PENDING');
    expect(DevPreviewData.paginatedRewardRedemptions.items, isNotEmpty);
  });
}
