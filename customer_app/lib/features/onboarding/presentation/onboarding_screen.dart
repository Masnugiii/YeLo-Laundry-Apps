import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _pages = [
    ('Laundry Mudah', 'Pesan pickup dan pantau progres cucian Anda.'),
    ('Wallet & Rewards', 'Kelola saldo dan kumpulkan poin reward.'),
    ('Notifikasi Real-time', 'Dapatkan update status order langsung.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = PageController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_laundry_service, size: 96, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(page.$1, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(page.$2, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () async {
                  await ref.read(preferencesProvider).setOnboardingComplete(true);
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Mulai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
