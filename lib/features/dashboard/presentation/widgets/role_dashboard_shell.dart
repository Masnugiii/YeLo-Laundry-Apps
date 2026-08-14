import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_shell_tab_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operational_summary_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/erp_bottom_navigation.dart';

class RoleDashboardShell extends ConsumerStatefulWidget {
  const RoleDashboardShell({
    super.key,
    required this.role,
    required this.pages,
    this.backgroundColor = AppColors.background,
  });

  final UserRole role;
  final List<Widget> pages;
  final Color backgroundColor;

  @override
  ConsumerState<RoleDashboardShell> createState() => _RoleDashboardShellState();
}

class _RoleDashboardShellState extends ConsumerState<RoleDashboardShell> {
  int get _activeIndex {
    if (widget.role == UserRole.laundry) {
      return ref.watch(binatuDashboardTabProvider);
    }
    return ref.watch(dashboardShellTabProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex;
    final maxIndex = widget.pages.length - 1;
    final safeActiveIndex = activeIndex.clamp(0, maxIndex);

    final summaryAsync = ref.watch(operationalSummaryProvider);
    final orderBadgeCount = summaryAsync.maybeWhen(
      data: (summary) => summary.newOrders,
      orElse: () => 0,
    );

    return Scaffold(
      key: ValueKey('${widget.role.name}-dashboard-shell'),
      backgroundColor: widget.backgroundColor,
      body: IndexedStack(
        index: safeActiveIndex,
        children: [
          for (var i = 0; i < widget.pages.length; i++)
            KeyedSubtree(
              key: ValueKey('${widget.role.name}-dashboard-tab-$i'),
              child: widget.pages[i],
            ),
        ],
      ),
      bottomNavigationBar: ErpBottomNavigation(
        role: widget.role,
        permissions: staffPermissionsFromSession(ref.watch(sessionProvider)),
        currentIndex: safeActiveIndex,
        orderBadgeCount: orderBadgeCount,
        onTap: (index) {
          final nextIndex = index.clamp(0, maxIndex);
          if (widget.role == UserRole.laundry) {
            ref.read(binatuDashboardTabProvider.notifier).setTab(nextIndex);
          } else {
            ref.read(dashboardShellTabProvider.notifier).setTab(nextIndex);
          }
        },
      ),
    );
  }
}
