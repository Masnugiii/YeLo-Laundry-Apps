import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/config/app_config.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';

class NotificationListState {
  const NotificationListState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.unreadCount,
  });

  final List<Map<String, dynamic>> items;
  final int page;
  final bool hasMore;
  final int unreadCount;
}

class NotificationListNotifier extends AsyncNotifier<NotificationListState> {
  @override
  Future<NotificationListState> build() async {
    return _load(page: 1);
  }

  Future<NotificationListState> _load({required int page}) async {
    final repository = ref.read(notificationRepositoryProvider);
    final response = await repository.fetchNotifications(
      page: page,
      limit: AppConfig.defaultPageSize,
    );
    final unreadCount = await repository.fetchUnreadCount();

    return NotificationListState(
      items: response.items,
      page: page,
      hasMore: page < response.meta.totalPages,
      unreadCount: unreadCount,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load(page: 1));
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    await refresh();
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    await refresh();
  }
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationRepositoryProvider).fetchUnreadCount();
});
