import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';

/// Navigable and gated modules across the ERP application.
enum AppModule {
  dashboard,
  customer,
  order,
  pickupDelivery,
  expenses,
  reports,
  attendance,
  settings,
  customerServiceCenter,
  yeloWallet,
  todaysTasks,
  orderQueue,
  revenue,
  financialReport,
  employeeKpi,
  employeeManagement,
  laundryProfile,
  aiPlanner,
  developerMenu,
  notificationCenter,
}

class RoleNavItemDefinition {
  const RoleNavItemDefinition({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Dummy role permission map for UI navigation.
///
/// Will be replaced by backend authorization in a future sprint.
abstract final class RolePermissions {
  static const _ownerModules = {
    AppModule.dashboard,
    AppModule.customer,
    AppModule.order,
    AppModule.pickupDelivery,
    AppModule.expenses,
    AppModule.reports,
    AppModule.attendance,
    AppModule.settings,
    AppModule.customerServiceCenter,
    AppModule.revenue,
    AppModule.financialReport,
    AppModule.employeeKpi,
    AppModule.employeeManagement,
    AppModule.laundryProfile,
    AppModule.aiPlanner,
    AppModule.notificationCenter,
  };

  static const _cashierModules = {
    AppModule.dashboard,
    AppModule.customer,
    AppModule.order,
    AppModule.pickupDelivery,
    AppModule.yeloWallet,
    AppModule.customerServiceCenter,
    AppModule.settings,
    AppModule.notificationCenter,
  };

  static const _laundryModules = {
    AppModule.dashboard,
    AppModule.orderQueue,
    AppModule.attendance,
    AppModule.settings,
    AppModule.notificationCenter,
  };

  static const _cashierLaundryModules = {
    AppModule.dashboard,
    AppModule.customer,
    AppModule.order,
    AppModule.pickupDelivery,
    AppModule.yeloWallet,
    AppModule.customerServiceCenter,
    AppModule.settings,
    AppModule.notificationCenter,
    AppModule.attendance,
  };

  static const _cashierLaundryDriverModules = {
    AppModule.dashboard,
    AppModule.customer,
    AppModule.order,
    AppModule.pickupDelivery,
    AppModule.yeloWallet,
    AppModule.customerServiceCenter,
    AppModule.settings,
    AppModule.notificationCenter,
    AppModule.attendance,
  };

  static Set<AppModule> visibleModules(UserRole role) => switch (role) {
        UserRole.owner => _ownerModules,
        UserRole.cashier => _cashierModules,
        UserRole.cashierLaundry => _cashierLaundryModules,
        UserRole.cashierLaundryDriver => _cashierLaundryDriverModules,
        UserRole.laundry => _laundryModules,
      };

  static bool isModuleVisible(UserRole role, AppModule module) {
    return visibleModules(role).contains(module);
  }

  static const ownerBottomNav = [
    RoleNavItemDefinition(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    RoleNavItemDefinition(
      label: 'Customer',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    RoleNavItemDefinition(
      label: 'Order',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    RoleNavItemDefinition(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  static const cashierBottomNav = [
    RoleNavItemDefinition(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    RoleNavItemDefinition(
      label: 'Customer',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    RoleNavItemDefinition(
      label: 'Order',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    RoleNavItemDefinition(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  static const laundryBottomNav = [
    RoleNavItemDefinition(
      label: 'Dashboard',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    RoleNavItemDefinition(
      label: 'Ironing Queue',
      icon: Icons.iron_outlined,
      selectedIcon: Icons.iron,
    ),
    RoleNavItemDefinition(
      label: 'Attendance',
      icon: Icons.fingerprint_outlined,
      selectedIcon: Icons.fingerprint,
    ),
    RoleNavItemDefinition(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  static List<RoleNavItemDefinition> bottomNavItems(UserRole role) =>
      switch (role) {
        UserRole.owner => ownerBottomNav,
        UserRole.cashier => cashierBottomNav,
        UserRole.cashierLaundry => cashierBottomNav,
        UserRole.cashierLaundryDriver => cashierBottomNav,
        UserRole.laundry => laundryBottomNav,
      };

  static int? orderTabIndex(UserRole role) => switch (role) {
        UserRole.owner => 2,
        UserRole.cashier => 2,
        UserRole.cashierLaundry => 2,
        UserRole.cashierLaundryDriver => 2,
        UserRole.laundry => 1,
      };

  static AppModule? moduleForPath(String path) {
    if (path.startsWith('/dashboard-owner') ||
        path.startsWith('/dashboard-cashier') ||
        path.startsWith('/dashboard-laundry') ||
        path.startsWith('/dashboard-binatu') ||
        path == '/dashboard' ||
        path == '/role-check') {
      return AppModule.dashboard;
    }
    if (path.startsWith('/customers') || path.startsWith('/customer/')) {
      return AppModule.customer;
    }
    if (path.startsWith('/new-order') ||
        path.startsWith('/orders') ||
        path.startsWith('/unpaid-orders') ||
        path.startsWith('/order-payment') ||
        path.startsWith('/incoming-orders')) {
      return AppModule.order;
    }
    if (path.startsWith('/pickup-delivery')) {
      return AppModule.pickupDelivery;
    }
    if (path.startsWith('/expenses')) {
      return AppModule.expenses;
    }
    if (path.startsWith('/reports')) {
      return AppModule.reports;
    }
    if (path.startsWith('/operator/ironing-assistance') ||
        path.startsWith('/binatu/orders')) {
      return AppModule.attendance;
    }
    if (path.startsWith('/attendance')) {
      return AppModule.attendance;
    }
    if (path.startsWith('/settings')) {
      return AppModule.settings;
    }
    if (path.startsWith('/customer-service')) {
      return AppModule.customerServiceCenter;
    }
    if (path.startsWith('/wallet')) {
      return AppModule.yeloWallet;
    }
    if (path.startsWith('/monitoring-binatu')) {
      return AppModule.employeeKpi;
    }
    if (path.startsWith('/employee-performance')) {
      return AppModule.employeeKpi;
    }
    if (path.startsWith('/employee-master')) {
      return AppModule.employeeManagement;
    }
    if (path.startsWith('/notifications')) {
      return AppModule.notificationCenter;
    }

    return null;
  }

  static String? redirectForRole(UserRole role, String path) {
    if (path.startsWith('/attendance/personal')) {
      if (isModuleVisible(role, AppModule.attendance)) {
        return null;
      }
      return role.dashboardRoute;
    }

    if (path == '/attendance') {
      if (role == UserRole.owner) {
        return null;
      }
      if (isModuleVisible(role, AppModule.attendance)) {
        return '/attendance/personal';
      }
      return role.dashboardRoute;
    }

    final module = moduleForPath(path);
    if (module == null) {
      return null;
    }

    if (isModuleVisible(role, module)) {
      return null;
    }

    return role.dashboardRoute;
  }
}
