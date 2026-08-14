import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';
import 'package:yelo_laundry_erp/features/staff/providers/staff_admin_options.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';

export 'staff_admin_options.dart'
    show
        StaffAdminSessionException,
        currentWalletAdmin,
        shouldFetchEmployeeDirectory,
        walletAdminFromSession;

final staffAdminOptionsProvider = FutureProvider<List<WalletAdmin>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (!shouldFetchEmployeeDirectory(session)) {
    return [walletAdminFromSession(session)];
  }

  final response = await ref
      .read(employeeRepositoryProvider)
      .fetchEmployees(page: 1, limit: 100);

  return walletAdminsFromEmployeeList(
    session: session,
    employees: response.items.map(
      (employee) => (id: employee.id, fullName: employee.fullName),
    ),
  );
});

final expenseAdminOptionsProvider = FutureProvider<List<ExpenseAdmin>>((ref) async {
  final admins = await ref.watch(staffAdminOptionsProvider.future);
  return admins
      .map(
        (admin) => ExpenseAdmin(
          id: admin.id,
          name: admin.name,
          isCurrentUser: admin.isCurrentUser,
        ),
      )
      .toList();
});

ExpenseAdmin currentExpenseAdmin(List<ExpenseAdmin> admins) {
  return admins.firstWhere(
    (admin) => admin.isCurrentUser,
    orElse: () => admins.isNotEmpty
        ? admins.first
        : const ExpenseAdmin(
            id: '',
            name: 'Pengguna saat ini',
            isCurrentUser: true,
          ),
  );
}
