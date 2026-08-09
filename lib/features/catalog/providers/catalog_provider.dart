import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';

final catalogProvider = FutureProvider<List<LaundryService>>((ref) async {
  return ref.watch(catalogRepositoryProvider).fetchActiveServices();
});
