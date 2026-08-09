import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(notificationRepositoryProvider).getNotifications();
      if (mounted) setState(() => _items..clear()..addAll(result.items));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              await _load();
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) async {
                      await ref.read(notificationRepositoryProvider).delete(item.id);
                    },
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: item.isRead ? null : const Icon(Icons.circle, size: 10, color: Colors.red),
                      onTap: () => context.push('/notifications/${item.id}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
