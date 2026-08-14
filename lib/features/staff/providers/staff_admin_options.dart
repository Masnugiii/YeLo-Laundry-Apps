import 'package:yelo_laundry_erp/core/session/app_user_session.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';

class StaffAdminSessionException implements Exception {
  const StaffAdminSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Mirrors backend `GET /employees` access: OWNER and MANAGER only.
bool shouldFetchEmployeeDirectory(AppUserSession session) {
  return session.roles.any(
    (role) => role == 'OWNER' || role == 'MANAGER',
  );
}

WalletAdmin walletAdminFromSession(AppUserSession session) {
  if (session.id.isEmpty) {
    throw const StaffAdminSessionException(
      'Sesi tidak valid. Silakan login ulang.',
    );
  }

  final displayName = session.name.trim().isNotEmpty
      ? session.name.trim()
      : 'Pengguna saat ini';

  return WalletAdmin(
    id: session.id,
    name: displayName,
    isCurrentUser: true,
  );
}

List<WalletAdmin> walletAdminsFromEmployeeList({
  required AppUserSession session,
  required Iterable<({String id, String fullName})> employees,
}) {
  final admins = employees
      .map(
        (employee) => WalletAdmin(
          id: employee.id,
          name: employee.fullName,
          isCurrentUser: employee.id == session.id,
        ),
      )
      .toList();

  if (admins.every((admin) => !admin.isCurrentUser) && session.id.isNotEmpty) {
    admins.insert(0, walletAdminFromSession(session));
  }

  return admins;
}

WalletAdmin currentWalletAdmin(List<WalletAdmin> admins) {
  return admins.firstWhere(
    (admin) => admin.isCurrentUser,
    orElse: () => admins.isNotEmpty
        ? admins.first
        : const WalletAdmin(
            id: '',
            name: 'Pengguna saat ini',
            isCurrentUser: true,
          ),
  );
}
