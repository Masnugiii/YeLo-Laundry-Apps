import 'package:flutter_test/flutter_test.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/app_user_session.dart';
import 'package:yelo_laundry_erp/features/staff/providers/staff_admin_options.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';

AppUserSession _session({
  String id = 'emp-1',
  String name = 'Kasir Satu',
  List<String> roles = const ['CASHIER'],
}) {
  return AppUserSession(
    id: id,
    employeeCode: 'CSH-001',
    name: name,
    phone: '08123456789',
    role: UserRole.cashier,
    roles: roles,
    permissions: const ['wallet'],
    isAuthenticated: true,
  );
}

void main() {
  group('shouldFetchEmployeeDirectory', () {
    test('returns true for OWNER', () {
      expect(
        shouldFetchEmployeeDirectory(_session(roles: const ['OWNER'])),
        isTrue,
      );
    });

    test('returns true for MANAGER', () {
      expect(
        shouldFetchEmployeeDirectory(_session(roles: const ['MANAGER'])),
        isTrue,
      );
    });

    test('returns false for CASHIER', () {
      expect(
        shouldFetchEmployeeDirectory(_session(roles: const ['CASHIER'])),
        isFalse,
      );
    });
  });

  group('walletAdminFromSession', () {
    test('uses session name for cashier', () {
      final admin = walletAdminFromSession(
        _session(id: 'cashier-1', name: 'Budi Kasir'),
      );

      expect(admin.id, 'cashier-1');
      expect(admin.name, 'Budi Kasir');
      expect(admin.isCurrentUser, isTrue);
    });

    test('falls back to Pengguna saat ini when name is empty', () {
      final admin = walletAdminFromSession(
        _session(id: 'cashier-1', name: ''),
      );

      expect(admin.name, 'Pengguna saat ini');
    });

    test('throws when employee id is missing', () {
      expect(
        () => walletAdminFromSession(_session(id: '')),
        throwsA(isA<StaffAdminSessionException>()),
      );
    });
  });

  group('walletAdminsFromEmployeeList', () {
    test('prepends current user when not in employee list', () {
      final admins = walletAdminsFromEmployeeList(
        session: _session(id: 'owner-1', name: 'Owner', roles: const ['OWNER']),
        employees: const [
          (id: 'emp-2', fullName: 'Manager A'),
          (id: 'emp-3', fullName: 'Manager B'),
        ],
      );

      expect(admins.first.id, 'owner-1');
      expect(admins.first.isCurrentUser, isTrue);
      expect(admins, hasLength(3));
    });
  });

  group('currentWalletAdmin', () {
    test('prefers current user entry', () {
      final admins = [
        const WalletAdmin(id: 'emp-2', name: 'Manager A'),
        const WalletAdmin(id: 'cashier-1', name: 'Budi', isCurrentUser: true),
      ];

      expect(currentWalletAdmin(admins).id, 'cashier-1');
    });
  });
}
