import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';

class LaundryTrackingScreen extends ConsumerStatefulWidget {
  const LaundryTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<LaundryTrackingScreen> createState() =>
      _LaundryTrackingScreenState();
}

class _LaundryTrackingScreenState extends ConsumerState<LaundryTrackingScreen> {
  List<LaundryTrackingStep> _steps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final steps =
        await ref.read(orderRepositoryProvider).getLaundryTracking(widget.orderId);
    if (mounted) setState(() {
      _steps = steps;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Laundry')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _steps.length,
          itemBuilder: (context, index) {
            final step = _steps[index];
            final isCompleted = step.status == 'completed';
            final isCurrent = step.status == 'current';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isCurrent
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                      color: isCompleted || isCurrent ? Colors.green : Colors.grey,
                    ),
                    if (index < _steps.length - 1)
                      Container(width: 2, height: 40, color: Colors.grey.shade300),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label, style: Theme.of(context).textTheme.titleMedium),
                        if (step.completedAt != null)
                          Text(step.completedAt!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
