import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Bahasa'),
            subtitle: const Text('Indonesia'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Tema'),
            subtitle: const Text('Sistem'),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Notifikasi Push'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Syarat & Ketentuan'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Keluar'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
