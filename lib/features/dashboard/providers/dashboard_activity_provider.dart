import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/dashboard_activity_item.dart';
import 'package:yelo_laundry_erp/features/dashboard/utils/dashboard_activity_mapper.dart';

final dashboardActivityProvider =
    FutureProvider.autoDispose<List<DashboardActivityItem>>((ref) async {
  final today = DateDisplayHelper.todayApiDateParam();
  final response = await ref.read(orderRepositoryProvider).fetchOrders(
        page: 1,
        limit: 5,
        dateFrom: today,
        dateTo: today,
      );

  return response.items.map(mapOrderToDashboardActivity).toList();
});
