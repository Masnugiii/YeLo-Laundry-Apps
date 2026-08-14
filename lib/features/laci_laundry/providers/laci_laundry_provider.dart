import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/laci_laundry/data/laci_laundry_repository.dart';

final laciLaundryRepositoryProvider = Provider<LaciLaundryRepository>((ref) {
  return LaciLaundryRepository(ref.watch(apiClientProvider));
});

final laciLaundryLockersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(laciLaundryRepositoryProvider).fetchLockers();
});

final laciLaundryDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(laciLaundryRepositoryProvider).fetchDashboard();
});

final laciLaundryBoxProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, code) async {
  return ref.watch(laciLaundryRepositoryProvider).fetchBox(code);
});

final canManageStorageProvider = Provider<bool>((ref) {
  final roles = ref.watch(sessionProvider).roles;
  return roles.any((role) => role == 'MANAGER' || role == 'OPERATOR' || role == 'BINATU');
});
