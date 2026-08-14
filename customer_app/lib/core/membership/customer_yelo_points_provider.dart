import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

/// Backend-driven YeLo Point balance for Dashboard + YeLo Rewards.
///
/// Dev preview uses the new YeLo Rewards preview balance (not old 1.250 missions).
/// Production never silently falls back to session.loyaltyPoints.
final customerYeloPointsProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(authProvider);
  final session = auth.session;
  if (!session.isAuthenticated) return 0;

  if (kDebugMode && auth.isDevPreview) {
    return DevPreviewData.rewardSummary.currentPoints;
  }

  try {
    final summary = await ref.read(rewardRepositoryProvider).getSummary();
    return summary.currentPoints;
  } on ApiException {
    rethrow;
  }
});

Future<void> refreshCustomerYeloPoints(WidgetRef ref) async {
  ref.invalidate(customerYeloPointsProvider);
  await ref.read(customerYeloPointsProvider.future);
}
