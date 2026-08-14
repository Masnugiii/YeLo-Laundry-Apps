/// User-facing label for the MANAGER / [UserRole.cashierLaundryDriver] role.
const managerRoleDisplayLabel = 'Manajer';

/// Maps UI-only role keys to display labels without changing RBAC identifiers.
String staffRoleKeyDisplayLabel(String roleKey) =>
    roleKey == 'Manager' ? managerRoleDisplayLabel : roleKey;

/// Application user roles for role-based navigation.
///
/// Replaces backend authentication until login integration is added.
enum UserRole {
  owner,
  cashier,
  cashierLaundry,
  cashierLaundryDriver,
  laundry,
  driver,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.cashier => 'Kasir',
        UserRole.cashierLaundry => 'Kasir + Binatu',
        UserRole.cashierLaundryDriver => managerRoleDisplayLabel,
        UserRole.laundry => 'Binatu',
        UserRole.driver => 'Driver',
      };

  String get roleBadge => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.cashier => 'Kasir',
        UserRole.cashierLaundry => 'Kasir + Binatu',
        UserRole.cashierLaundryDriver => managerRoleDisplayLabel,
        UserRole.laundry => 'Binatu',
        UserRole.driver => 'Driver',
      };

  String get dashboardRoute => switch (this) {
        UserRole.owner => '/dashboard-owner',
        UserRole.cashier => '/dashboard-cashier',
        UserRole.cashierLaundry => '/dashboard-cashier-laundry',
        UserRole.cashierLaundryDriver => '/dashboard-cashier-laundry-driver',
        UserRole.laundry => '/dashboard-laundry',
        UserRole.driver => '/dashboard-driver',
      };
}
