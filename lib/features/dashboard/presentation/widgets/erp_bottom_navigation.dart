import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/role_permission.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_notification_badge.dart';

class ErpNavItem {
  const ErpNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class ErpBottomNavigation extends StatelessWidget {
  const ErpBottomNavigation({
    super.key,
    required this.role,
    required this.permissions,
    required this.currentIndex,
    required this.onTap,
    this.orderBadgeCount = 0,
  });

  final UserRole role;
  final StaffPermissions permissions;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int orderBadgeCount;

  List<ErpNavItem> get _items {
    return RolePermissions.bottomNavItems(role, permissions)
        .map(
          (item) => ErpNavItem(
            label: item.label,
            icon: item.icon,
            selectedIcon: item.selectedIcon,
          ),
        )
        .toList();
  }

  int? get _orderTabIndex {
    final navItems = RolePermissions.bottomNavItems(role, permissions);
    return RolePermissions.orderTabIndex(role, permissions, navItems);
  }

  Widget _badgedIcon(IconData iconData, {required bool showBadge}) {
    final icon = Icon(iconData);

    return ErpNotificationBadge(
      count: showBadge ? orderBadgeCount : 0,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.length < 2) {
      return const SizedBox.shrink();
    }

    final safeIndex = currentIndex.clamp(0, items.length - 1);
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return NavigationBar(
      selectedIndex: safeIndex,
      onDestinationSelected: onTap,
      labelBehavior: isCompact
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (var i = 0; i < items.length; i++)
          NavigationDestination(
            icon: _badgedIcon(
              items[i].icon,
              showBadge: _orderTabIndex != null && i == _orderTabIndex,
            ),
            selectedIcon: _badgedIcon(
              items[i].selectedIcon,
              showBadge: _orderTabIndex != null && i == _orderTabIndex,
            ),
            label: items[i].label,
          ),
      ],
    );
  }
}
