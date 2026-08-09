import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  const DeliveryTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await ref.read(orderRepositoryProvider).getDeliveryTracking(widget.orderId);
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

    if (_data == null) {
      return const Scaffold(
        body: Center(child: Text('Belum ada pengiriman aktif untuk order ini.')),
      );
    }

    final driver = _data!['driver'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Pengiriman')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_data!['status']}'),
            const SizedBox(height: 8),
            Text('Jadwal: ${_data!['scheduledDeliveryAt'] ?? '-'}'),
            const SizedBox(height: 16),
            if (driver != null) ...[
              Text('Driver', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                leading: const Icon(Icons.drive_eta),
                title: Text(driver['fullName']?.toString() ?? '-'),
                subtitle: Text(driver['phone']?.toString() ?? '-'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
