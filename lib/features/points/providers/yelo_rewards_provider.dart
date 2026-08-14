import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';

final yeloRewardsSummaryProvider =
    FutureProvider.family<YeloRewardsSummary, String>((ref, customerId) async {
  return ref.watch(loyaltyRepositoryProvider).fetchYeloRewardsSummary(customerId);
});

final rewardCatalogProvider =
    FutureProvider.family<List<RewardCatalogItem>, String>((ref, customerId) {
  return ref
      .watch(loyaltyRepositoryProvider)
      .fetchRewardCatalog(customerId: customerId);
});

final activeCksEntitlementsProvider =
    FutureProvider.family<List<CksEntitlement>, String>((ref, customerId) async {
  return ref
      .watch(loyaltyRepositoryProvider)
      .fetchActiveCksEntitlements(customerId);
});
