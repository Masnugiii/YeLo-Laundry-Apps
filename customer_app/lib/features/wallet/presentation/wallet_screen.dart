import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  double _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final customerId = ref.read(sessionProvider).id;
      final wallet = await ref.read(walletRepositoryProvider).getWallet(customerId);
      if (mounted) setState(() => _balance = wallet.balance);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () => context.push('/wallet/history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo Saat Ini', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(currency.format(_balance), style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push('/wallet/history'),
                    child: const Text('Lihat Riwayat Transaksi'),
                  ),
                ],
              ),
            ),
    );
  }
}
