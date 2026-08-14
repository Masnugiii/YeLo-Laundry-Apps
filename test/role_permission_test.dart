import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/role_permission.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';

void main() {
  group('RolePermissions storage access', () {
    const withoutStorage = StaffPermissions([]);

    test('all internal roles can view laci laundry', () {
      for (final role in UserRole.values) {
        expect(
          RolePermissions.canViewStorage(role, withoutStorage),
          isTrue,
          reason: '${role.name} should open Laci Laundry',
        );
        expect(
          RolePermissions.redirectForSession(
            role,
            withoutStorage,
            '/laci-laundry',
          ),
          isNull,
          reason: '${role.name} should not be redirected away from Laci Laundry',
        );
      }
    });

    test('all internal roles can open storage box detail route', () {
      expect(
        RolePermissions.redirectForSession(
          UserRole.owner,
          withoutStorage,
          '/laci-laundry/box/A-01',
        ),
        isNull,
      );
      expect(
        RolePermissions.redirectForSession(
          UserRole.driver,
          withoutStorage,
          '/laci-laundry/box/A-01',
        ),
        isNull,
      );
    });
  });

  group('RolePermissions bottom navigation shell', () {
    const emptyPermissions = StaffPermissions([]);

    test('cashier always has four shell destinations', () {
      final items = RolePermissions.bottomNavItems(UserRole.cashier, emptyPermissions);
      expect(items.length, 4);
      expect(items.map((item) => item.label).toList(), [
        'Beranda',
        'Customer',
        'Order',
        'Akun',
      ]);
    });

    test('driver always has four shell destinations', () {
      final items = RolePermissions.bottomNavItems(UserRole.driver, emptyPermissions);
      expect(items.length, 4);
      expect(items.map((item) => item.label).toList(), [
        'Beranda',
        'Pickup',
        'Kehadiran',
        'Notifikasi',
      ]);
    });

    test('binatu always has four shell destinations', () {
      final items = RolePermissions.bottomNavItems(UserRole.laundry, emptyPermissions);
      expect(items.length, 4);
      expect(items.map((item) => item.label).toList(), [
        'Beranda',
        'Antrian',
        'Kehadiran',
        'Akun',
      ]);
    });

    test('owner and manager shells have four destinations', () {
      for (final role in [
        UserRole.owner,
        UserRole.cashierLaundry,
        UserRole.cashierLaundryDriver,
      ]) {
        final items = RolePermissions.bottomNavItems(role, emptyPermissions);
        expect(items.length, greaterThanOrEqualTo(2));
        expect(items.length, 4);
      }
    });
  });

  group('RolePermissions wallet routes', () {
    test('wallet history requires wallet view permission', () {
      const viewOnly = StaffPermissions(['wallet']);
      expect(
        RolePermissions.redirectForSession(
          UserRole.cashierLaundryDriver,
          viewOnly,
          '/wallet-history?customerId=abc',
        ),
        isNull,
      );
      expect(
        RolePermissions.redirectForSession(
          UserRole.cashierLaundryDriver,
          const StaffPermissions([]),
          '/wallet-history?customerId=abc',
        ),
        UserRole.cashierLaundryDriver.dashboardRoute,
      );
    });

    test('wallet top up routes require wallet_topup permission', () {
      const viewOnly = StaffPermissions(['wallet']);
      const withTopUp = StaffPermissions(['wallet', 'wallet_topup']);

      expect(
        RolePermissions.redirectForSession(
          UserRole.cashier,
          viewOnly,
          '/wallet-top-up/review',
        ),
        UserRole.cashier.dashboardRoute,
      );
      expect(
        RolePermissions.redirectForSession(
          UserRole.cashier,
          withTopUp,
          '/wallet-top-up/review',
        ),
        isNull,
      );
    });

    test('wallet deduct routes require wallet_deduct permission', () {
      const viewOnly = StaffPermissions(['wallet']);
      final withDeduct = StaffPermissions(['wallet', 'wallet_deduct']);

      expect(
        RolePermissions.redirectForSession(
          UserRole.cashierLaundryDriver,
          viewOnly,
          '/wallet-deduction/review',
        ),
        UserRole.cashierLaundryDriver.dashboardRoute,
      );
      expect(
        RolePermissions.redirectForSession(
          UserRole.cashierLaundryDriver,
          withDeduct,
          '/wallet-deduction/review',
        ),
        isNull,
      );
    });
  });
}
