import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_shell_tab_provider.dart';

/// Returns the role dashboard shell to the Beranda tab (index 0).
void goToDashboardHome(WidgetRef ref) {
  ref.read(dashboardShellTabProvider.notifier).setTab(0);
  ref.read(binatuDashboardTabProvider.notifier).setTab(0);
}

/// AppBar back icon for bottom-nav tab pages (Customer, Order, Akun).
class DashboardAppBarBackButton extends ConsumerWidget {
  const DashboardAppBarBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButton(
      color: AppColors.onPrimary,
      onPressed: () => goToDashboardHome(ref),
    );
  }
}
