import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends ConsumerState<NotificationDetailScreen> {
  AppNotification? _notification;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notification =
        await ref.read(notificationRepositoryProvider).getDetail(widget.notificationId);
    await ref.read(notificationRepositoryProvider).markRead(widget.notificationId);
    if (mounted) setState(() {
      _notification = notification;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _notification == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = _notification!;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Notifikasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.createdAt, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Text(item.message),
          ],
        ),
      ),
    );
  }
}
