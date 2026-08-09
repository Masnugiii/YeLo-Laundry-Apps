/// Application user roles for role-based navigation.
///
/// Replaces backend authentication until login integration is added.
enum UserRole {
  owner,
  cashier,
  cashierLaundry,
  cashierLaundryDriver,
  laundry,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.cashier => 'Kasir',
        UserRole.cashierLaundry => 'Kasir + Binatu',
        UserRole.cashierLaundryDriver => 'Kasir + Binatu + Driver',
        UserRole.laundry => 'Binatu',
      };

  String get roleBadge => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.cashier => 'Kasir',
        UserRole.cashierLaundry => 'Kasir + Binatu',
        UserRole.cashierLaundryDriver => 'Kasir + Binatu + Driver',
        UserRole.laundry => 'Binatu',
      };

  String get dashboardRoute => switch (this) {
        UserRole.owner => '/dashboard-owner',
        UserRole.cashier => '/dashboard-cashier',
        UserRole.cashierLaundry => '/dashboard-cashier-laundry',
        UserRole.cashierLaundryDriver => '/dashboard-cashier-laundry-driver',
        UserRole.laundry => '/dashboard-laundry',
      };
}
