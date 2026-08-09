import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';

class OrderTimelineScreen extends ConsumerStatefulWidget {
  const OrderTimelineScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTimelineScreen> createState() => _OrderTimelineScreenState();
}

class _OrderTimelineScreenState extends ConsumerState<OrderTimelineScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(orderRepositoryProvider).getTimeline(widget.orderId);
    if (mounted) setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final timeline = (_data?['timeline'] as List<dynamic>? ?? []);
    final history = (_data?['statusHistory'] as List<dynamic>? ?? []);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Timeline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
          ...timeline.map(
            (item) => ListTile(
              leading: const Icon(Icons.timeline),
              title: Text(item['title']?.toString() ?? item['type']?.toString() ?? 'Event'),
              subtitle: Text(item['description']?.toString() ?? ''),
            ),
          ),
          const Divider(),
          Text('Riwayat Status', style: Theme.of(context).textTheme.titleMedium),
          ...history.map(
            (item) => ListTile(
              title: Text(item['toStatus']?.toString() ?? item['currentStatus']?.toString() ?? ''),
              subtitle: Text(item['changedAt']?.toString() ?? item['createdAt']?.toString() ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}
