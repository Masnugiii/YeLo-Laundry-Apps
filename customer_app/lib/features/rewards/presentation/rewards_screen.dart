import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  RewardSummary? _summary;
  final List<RewardHistoryItem> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await ref.read(rewardRepositoryProvider).getSummary();
      final history = await ref.read(rewardRepositoryProvider).getHistory();
      if (mounted) {
        setState(() {
          _summary = summary;
          _history
            ..clear()
            ..addAll(history.items);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _summary == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reward Points')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Poin Aktif'),
                    Text('${_summary!.currentPoints}', style: Theme.of(context).textTheme.headlineMedium),
                    Text('Poin kedaluwarsa: ${_summary!.expiredPoints}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Riwayat', style: Theme.of(context).textTheme.titleMedium),
            ..._history.map(
              (item) => ListTile(
                title: Text('${item.point} poin'),
                subtitle: Text(item.description ?? item.type),
                trailing: Text(item.expiredAt != null ? 'Exp: ${item.expiredAt}' : ''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
