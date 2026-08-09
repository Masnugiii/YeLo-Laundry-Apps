import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/erp_bottom_navigation.dart';
import 'package:yelo_laundry_erp/features/orders/data/dummy_incoming_orders.dart';

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
  int _currentIndex = 0;

  int get _activeIndex {
    if (widget.role == UserRole.laundry) {
      return ref.watch(binatuDashboardTabProvider);
    }
    return _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex;

    return Scaffold(
      key: ValueKey('${widget.role.name}-dashboard-shell'),
      backgroundColor: widget.backgroundColor,
      body: IndexedStack(
        index: activeIndex,
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
        currentIndex: activeIndex,
        orderBadgeCount: dummyNewIncomingOrderCount(),
        onTap: (index) {
          if (widget.role == UserRole.laundry) {
            ref.read(binatuDashboardTabProvider.notifier).setTab(index);
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}
