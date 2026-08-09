import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  final List<WalletTransaction> _items = [];
  bool _loading = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final customerId = ref.read(sessionProvider).id;
      final result = await ref.read(walletRepositoryProvider).getTransactions(
            customerId,
            page: _page,
          );
      setState(() {
        _items.addAll(result.items);
        _hasMore = _page < result.meta.totalPages;
        _page++;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Wallet')),
      body: ListView.builder(
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            _load();
            return const Center(child: CircularProgressIndicator());
          }
          final item = _items[index];
          return ListTile(
            title: Text(item.type),
            subtitle: Text(item.notes ?? item.referenceNumber ?? ''),
            trailing: Text(currency.format(item.amount)),
          );
        },
      ),
    );
  }
}
