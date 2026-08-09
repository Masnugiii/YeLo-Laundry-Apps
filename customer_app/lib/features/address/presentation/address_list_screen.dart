import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  List<CustomerAddress> _addresses = [];
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
      final addresses = await ref.read(addressRepositoryProvider).list(customerId);
      if (mounted) setState(() => _addresses = addresses);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final customerId = ref.read(sessionProvider).id;
    await ref.read(addressRepositoryProvider).delete(customerId, id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push('/addresses/add');
              await _load();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(address.recipientName),
                      subtitle: Text(address.fullAddress),
                      trailing: address.isDefault
                          ? const Chip(label: Text('Default'))
                          : null,
                      onTap: () async {
                        await context.push('/addresses/${address.id}/edit');
                        await _load();
                      },
                      onLongPress: () => _delete(address.id),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
