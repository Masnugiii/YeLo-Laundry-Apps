import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(session.fullName.isNotEmpty ? session.fullName[0] : '?')),
            title: Text(session.fullName),
            subtitle: Text(session.phone),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/edit'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Alamat Saya'),
            onTap: () => context.push('/addresses'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Wallet'),
            onTap: () => context.push('/wallet'),
          ),
          ListTile(
            leading: const Icon(Icons.stars_outlined),
            title: const Text('Reward Points'),
            onTap: () => context.push('/rewards'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pusat Bantuan'),
            onTap: () => context.push('/help'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang'),
            onTap: () => context.push('/about'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
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
