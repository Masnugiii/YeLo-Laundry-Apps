import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/customer_bottom_nav.dart';

export 'package:yelo_laundry_customer/features/home/presentation/home_dashboard_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDevPreview = ref.watch(authProvider).isDevPreview;

    return Scaffold(
      body: Column(
        children: [
          if (kDebugMode && isDevPreview)
            MaterialBanner(
              content: const Text(
                'Mode Preview Development — data dummy, tidak terhubung ke server.',
              ),
              leading: const Icon(Icons.developer_mode),
              backgroundColor: AppColors.brandYellow.withValues(alpha: 0.28),
              actions: [
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Keluar Preview'),
                ),
              ],
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentShellIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
      ),
    );
  }
}
