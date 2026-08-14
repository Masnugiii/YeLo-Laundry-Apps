import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';

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
  storage,
  shellHome,
  shellAccount,
}

class RoleNavItemDefinition {
  const RoleNavItemDefinition({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.module,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final AppModule module;
}

/// Permission-driven navigation derived from backend JWT permissions.
abstract final class RolePermissions {
  static const Map<AppModule, List<String>> _modulePermissions = {
    AppModule.dashboard: [PermissionCodes.dashboard],
    AppModule.customer: [PermissionCodes.customers],
    AppModule.order: [PermissionCodes.orders],
    AppModule.pickupDelivery: [
      PermissionCodes.pickup,
      PermissionCodes.delivery,
    ],
    AppModule.expenses: [PermissionCodes.finance],
    AppModule.reports: [PermissionCodes.reports],
    AppModule.attendance: [PermissionCodes.attendance],
    AppModule.settings: [PermissionCodes.settings],
    AppModule.customerServiceCenter: [PermissionCodes.customerService],
    AppModule.yeloWallet: [PermissionCodes.wallet],
    AppModule.todaysTasks: [PermissionCodes.orders],
    AppModule.orderQueue: [PermissionCodes.ironing],
    AppModule.revenue: [PermissionCodes.reports, PermissionCodes.finance],
    AppModule.financialReport: [PermissionCodes.reports, PermissionCodes.finance],
    AppModule.employeeKpi: [PermissionCodes.reports],
    AppModule.employeeManagement: [PermissionCodes.settings],
    AppModule.laundryProfile: [PermissionCodes.settings],
    AppModule.aiPlanner: [PermissionCodes.reports],
    AppModule.notificationCenter: [PermissionCodes.notification],
    AppModule.storage: [PermissionCodes.storage],
    AppModule.shellHome: [],
    AppModule.shellAccount: [],
    AppModule.developerMenu: [],
  };

  /// All internal staff roles can open Laci Laundry for checking.
  ///
  /// Mutation access is gated separately via [canManageStorageProvider].
  static bool canViewStorage(UserRole role, StaffPermissions permissions) {
    return switch (role) {
      UserRole.owner ||
      UserRole.cashier ||
      UserRole.cashierLaundry ||
      UserRole.cashierLaundryDriver ||
      UserRole.laundry ||
      UserRole.driver =>
        true,
    };
  }

  static bool isModuleVisible(
    StaffPermissions permissions,
    AppModule module,
  ) {
    final required = _modulePermissions[module];
    if (required == null || required.isEmpty) {
      return true;
    }
    return permissions.hasAny(required);
  }

  static Set<AppModule> visibleModules(StaffPermissions permissions) {
    return AppModule.values
        .where((module) => isModuleVisible(permissions, module))
        .toSet();
  }

  static const _operationalShellBottomNav = [
    RoleNavItemDefinition(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      module: AppModule.shellHome,
    ),
    RoleNavItemDefinition(
      label: 'Customer',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      module: AppModule.customer,
    ),
    RoleNavItemDefinition(
      label: 'Order',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      module: AppModule.order,
    ),
    RoleNavItemDefinition(
      label: 'Akun',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      module: AppModule.shellAccount,
    ),
  ];

  static const _cashierBottomNav = _operationalShellBottomNav;

  static const _laundryBottomNav = [
    RoleNavItemDefinition(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      module: AppModule.shellHome,
    ),
    RoleNavItemDefinition(
      label: 'Antrian',
      icon: Icons.iron_outlined,
      selectedIcon: Icons.iron,
      module: AppModule.orderQueue,
    ),
    RoleNavItemDefinition(
      label: 'Kehadiran',
      icon: Icons.fingerprint_outlined,
      selectedIcon: Icons.fingerprint,
      module: AppModule.attendance,
    ),
    RoleNavItemDefinition(
      label: 'Akun',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      module: AppModule.shellAccount,
    ),
  ];

  static const _driverBottomNav = [
    RoleNavItemDefinition(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      module: AppModule.shellHome,
    ),
    RoleNavItemDefinition(
      label: 'Pickup',
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping,
      module: AppModule.pickupDelivery,
    ),
    RoleNavItemDefinition(
      label: 'Kehadiran',
      icon: Icons.fingerprint_outlined,
      selectedIcon: Icons.fingerprint,
      module: AppModule.attendance,
    ),
    RoleNavItemDefinition(
      label: 'Notifikasi',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      module: AppModule.notificationCenter,
    ),
  ];

  static List<RoleNavItemDefinition> _candidatesForRole(UserRole role) {
    return switch (role) {
      UserRole.laundry => _laundryBottomNav,
      UserRole.driver => _driverBottomNav,
      UserRole.owner ||
      UserRole.cashier ||
      UserRole.cashierLaundry ||
      UserRole.cashierLaundryDriver =>
        _cashierBottomNav,
    };
  }

  static List<RoleNavItemDefinition> bottomNavItems(
    UserRole role,
    StaffPermissions permissions,
  ) {
    // Shell navigation must stay aligned with dashboard pages and always
    // provide at least two destinations for Material NavigationBar.
    return List.unmodifiable(_candidatesForRole(role));
  }

  static int? orderTabIndex(
    UserRole role,
    StaffPermissions permissions,
    List<RoleNavItemDefinition> items,
  ) {
    final orderModule = role == UserRole.laundry
        ? AppModule.orderQueue
        : AppModule.order;
    final index = items.indexWhere((item) => item.module == orderModule);
    return index == -1 ? null : index;
  }

  static AppModule? moduleForPath(String path) {
    if (path.startsWith('/dashboard-owner') ||
        path.startsWith('/dashboard-cashier') ||
        path.startsWith('/dashboard-laundry') ||
        path.startsWith('/dashboard-binatu') ||
        path.startsWith('/dashboard-driver') ||
        path.startsWith('/dashboard-cashier-laundry') ||
        path.startsWith('/dashboard-cashier-laundry-driver') ||
        path == '/dashboard' ||
        path == '/role-check') {
      return AppModule.shellHome;
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
      return AppModule.orderQueue;
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
    if (path.startsWith('/laci-laundry')) {
      return AppModule.storage;
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

  static String? redirectForSession(
    UserRole role,
    StaffPermissions permissions,
    String path,
  ) {
    if (path.startsWith('/attendance/personal')) {
      if (isModuleVisible(permissions, AppModule.attendance)) {
        return null;
      }
      return role.dashboardRoute;
    }

    if (path == '/attendance') {
      if (permissions.dashboard) {
        return null;
      }
      if (isModuleVisible(permissions, AppModule.attendance)) {
        return '/attendance/personal';
      }
      return role.dashboardRoute;
    }

    if (path.startsWith('/wallet-top-up') || path == '/wallet-top-up-success') {
      if (permissions.walletTopUp) {
        return null;
      }
      return role.dashboardRoute;
    }

    if (path.startsWith('/wallet-deduction') || path == '/wallet-payment-success') {
      if (permissions.walletDeduct) {
        return null;
      }
      return role.dashboardRoute;
    }

    if (path.startsWith('/wallet-history')) {
      if (permissions.wallet) {
        return null;
      }
      return role.dashboardRoute;
    }

    final module = moduleForPath(path);
    if (module == null) {
      return null;
    }

    if (module == AppModule.storage) {
      if (canViewStorage(role, permissions)) {
        return null;
      }
      return role.dashboardRoute;
    }

    if (isModuleVisible(permissions, module)) {
      return null;
    }

    return role.dashboardRoute;
  }
}
