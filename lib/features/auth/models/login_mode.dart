import 'package:yelo_laundry_erp/core/role/role.dart';

/// Development-only operational modes for previewing role-specific dashboards.
enum LoginMode {
  owner,
  cashierOperational,
  cashierLaundry,
  cashierLaundryDriver,
  binatu;

  static const String devPassword = 'admin123';
}

extension LoginModeX on LoginMode {
  String get emoji => switch (this) {
        LoginMode.owner => '👑',
        LoginMode.cashierOperational => '🏪',
        LoginMode.cashierLaundry => '👤',
        LoginMode.cashierLaundryDriver => '👤',
        LoginMode.binatu => '🧺',
      };

  String get title => switch (this) {
        LoginMode.owner => 'Owner',
        LoginMode.cashierOperational => 'Kasir - HP Operasional',
        LoginMode.cashierLaundry => 'Kasir + Binatu - HP Pribadi',
        LoginMode.cashierLaundryDriver =>
          'Kasir + Binatu + Driver - HP Pribadi',
        LoginMode.binatu => 'Binatu',
      };

  String get description => switch (this) {
        LoginMode.owner =>
          'Mengakses seluruh fitur Yelo Laundry ERP.',
        LoginMode.cashierOperational =>
          'Digunakan pada HP operasional yang berada di meja kasir.\n'
          'Tidak memiliki menu Kehadiran.\n'
          'Digunakan untuk melayani pelanggan dan transaksi harian.',
        LoginMode.cashierLaundry =>
          'Digunakan oleh karyawan yang merangkap sebagai Kasir dan Binatu '
          'menggunakan HP pribadi.\n'
          'Memiliki menu Kehadiran.\n'
          'Dapat menerima pekerjaan setrika.\n'
          'Dapat melihat progress seluruh order karena juga bertugas sebagai kasir.',
        LoginMode.cashierLaundryDriver =>
          'Digunakan oleh karyawan yang merangkap sebagai Kasir, Binatu, '
          'dan Driver menggunakan HP pribadi.\n'
          'Memiliki menu Kehadiran.\n'
          'Dapat melakukan Pickup & Delivery.\n'
          'Dapat menerima pekerjaan setrika.',
        LoginMode.binatu =>
          'Digunakan oleh karyawan bagian Binatu.\n'
          'Fokus pada pekerjaan setrika dan finishing.\n'
          'Tidak memiliki akses ke Customer, Pembayaran, Wallet, maupun Laporan.',
      };

  List<String> get includes => switch (this) {
        LoginMode.owner => [
          'Dashboard Owner',
          'Laporan',
          'Pengeluaran',
          'KPI',
          'AI Planner',
          'Settings',
        ],
        LoginMode.cashierOperational => [
          'Dashboard Kasir',
          'Customer',
          'Order',
          'Pickup & Delivery',
          'Yelo Wallet',
          'Notification Center',
          'Customer Service Center',
          'Settings',
        ],
        LoginMode.cashierLaundry => [
          'Dashboard',
          'Customer',
          'Order',
          'Pickup & Delivery',
          'Notification Center',
          'Kehadiran',
          'Settings',
        ],
        LoginMode.cashierLaundryDriver => [
          'Dashboard',
          'Customer',
          'Order',
          'Pickup & Delivery',
          'Driver',
          'Maps',
          'Notification Center',
          'Kehadiran',
          'Settings',
        ],
        LoginMode.binatu => [
          'Dashboard Binatu',
          'Antrian Setrika',
          'Sedang Disetrika',
          'Selesai Disetrika',
          'Notification Center',
          'Kehadiran',
          'Settings',
        ],
      };

  String get buttonLabel => switch (this) {
        LoginMode.owner => 'Masuk sebagai Owner',
        LoginMode.cashierOperational => 'Masuk sebagai Kasir - HP Operasional',
        LoginMode.cashierLaundry => 'Masuk sebagai Kasir + Binatu',
        LoginMode.cashierLaundryDriver =>
          'Masuk sebagai Kasir + Binatu + Driver',
        LoginMode.binatu => 'Masuk sebagai Binatu',
      };

  String get dashboardRoute => switch (this) {
        LoginMode.owner => '/dashboard-owner',
        LoginMode.cashierOperational => '/dashboard-cashier',
        LoginMode.cashierLaundry => '/dashboard-cashier-laundry',
        LoginMode.cashierLaundryDriver => '/dashboard-cashier-laundry-driver',
        LoginMode.binatu => '/dashboard-laundry',
      };

  UserRole get previewRole => switch (this) {
        LoginMode.owner => UserRole.owner,
        LoginMode.cashierOperational => UserRole.cashier,
        LoginMode.cashierLaundry => UserRole.cashierLaundry,
        LoginMode.cashierLaundryDriver => UserRole.cashierLaundryDriver,
        LoginMode.binatu => UserRole.laundry,
      };

  /// Seeded development account phone for each operational mode.
  String get devPhone => switch (this) {
        LoginMode.owner => '081234567890',
        LoginMode.cashierOperational => '081234567891',
        LoginMode.cashierLaundry => '081234567892',
        LoginMode.cashierLaundryDriver => '081234567893',
        LoginMode.binatu => '081234567894',
      };

  /// Whether the target dashboard screen has been implemented.
  bool get isDashboardAvailable => switch (this) {
        LoginMode.owner => true,
        LoginMode.cashierOperational => true,
        LoginMode.cashierLaundry => true,
        LoginMode.cashierLaundryDriver => true,
        LoginMode.binatu => true,
      };
}
