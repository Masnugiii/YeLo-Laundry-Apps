import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/session/app_user_session.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';

/// Backend permission codes mirrored from NestJS `PERMISSIONS` constants.
abstract final class PermissionCodes {
  static const dashboard = 'dashboard';
  static const orders = 'orders';
  static const finance = 'finance';
  static const customers = 'customers';
  static const wallet = 'wallet';
  static const walletTopUp = 'wallet_topup';
  static const walletDeduct = 'wallet_deduct';
  static const loyalty = 'loyalty';
  static const attendance = 'attendance';
  static const ironing = 'ironing';
  static const pickup = 'pickup';
  static const delivery = 'delivery';
  static const reports = 'reports';
  static const settings = 'settings';
  static const notification = 'notification';
  static const customerService = 'customer_service';
  static const storage = 'storage';
}

class StaffPermissions {
  const StaffPermissions(this._permissions);

  final List<String> _permissions;

  bool has(String code) => _permissions.contains(code);

  bool hasAny(Iterable<String> codes) =>
      codes.any((code) => _permissions.contains(code));

  bool get dashboard => has(PermissionCodes.dashboard);
  bool get orders => has(PermissionCodes.orders);
  bool get finance => has(PermissionCodes.finance);
  bool get customers => has(PermissionCodes.customers);
  bool get wallet => has(PermissionCodes.wallet);
  bool get walletTopUp => has(PermissionCodes.walletTopUp);
  bool get walletDeduct => has(PermissionCodes.walletDeduct);
  bool get loyalty => has(PermissionCodes.loyalty);
  bool get attendance => has(PermissionCodes.attendance);
  bool get ironing => has(PermissionCodes.ironing);
  bool get pickup => has(PermissionCodes.pickup);
  bool get delivery => has(PermissionCodes.delivery);
  bool get reports => has(PermissionCodes.reports);
  bool get settings => has(PermissionCodes.settings);
  bool get notification => has(PermissionCodes.notification);
  bool get customerService => has(PermissionCodes.customerService);
  bool get storage => has(PermissionCodes.storage);

  bool get pickupDelivery => hasAny([PermissionCodes.pickup, PermissionCodes.delivery]);
  bool get unpaidOrders => hasAny([PermissionCodes.orders, PermissionCodes.finance]);
  bool get expenses => finance;
  bool get revenueReport => reports;
  bool get financialDashboard => hasAny([PermissionCodes.reports, PermissionCodes.finance]);
  bool get employeeKpi => reports;
  bool get employeeManagement => settings;
  bool get laundryProfile => settings;
  bool get systemSettings => settings;
  bool get aiPlanner => reports;
  bool get ownerData => dashboard;
  bool get ironingQueueAssistance => ironing;
  bool get orderNumberSettingsReadOnly => settings;
  bool get receiptPrinterSettings => settings;
  bool get printReceipt => orders;
  bool get shareReceiptWhatsapp => orders;
}

final staffPermissionsProvider = Provider<StaffPermissions>((ref) {
  return StaffPermissions(ref.watch(sessionProvider).permissions);
});

StaffPermissions staffPermissionsFromSession(AppUserSession session) {
  return StaffPermissions(session.permissions);
}
