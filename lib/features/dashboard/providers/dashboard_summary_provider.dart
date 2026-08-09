import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';

final ownerDashboardSummaryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchOwnerSummary();
});
