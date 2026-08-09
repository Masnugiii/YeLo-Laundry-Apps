import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/role_permission.dart';
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
    required this.currentIndex,
    required this.onTap,
    this.orderBadgeCount = 0,
  });

  final UserRole role;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int orderBadgeCount;

  List<ErpNavItem> get _items {
    return RolePermissions.bottomNavItems(role)
        .map(
          (item) => ErpNavItem(
            label: item.label,
            icon: item.icon,
            selectedIcon: item.selectedIcon,
          ),
        )
        .toList();
  }

  int? get _orderTabIndex => RolePermissions.orderTabIndex(role);

  Widget _badgedIcon(IconData iconData, {required bool showBadge}) {
    final icon = Icon(iconData);

    return ErpNotificationBadge(
      count: showBadge ? orderBadgeCount : 0,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelBehavior: isCompact
          ? NavigationDestinationLabelBehavior.onlyShowSelected
          : NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (var i = 0; i < _items.length; i++)
          NavigationDestination(
            icon: _badgedIcon(
              _items[i].icon,
              showBadge: _orderTabIndex != null && i == _orderTabIndex,
            ),
            selectedIcon: _badgedIcon(
              _items[i].selectedIcon,
              showBadge: _orderTabIndex != null && i == _orderTabIndex,
            ),
            label: _items[i].label,
          ),
      ],
    );
  }
}
