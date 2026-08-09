import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';

const dummyExpenseAdmins = <ExpenseAdmin>[
  ExpenseAdmin(id: 'exp-admin-owner', name: 'Owner', isCurrentUser: true),
  ExpenseAdmin(id: 'exp-admin-andi', name: 'Kasir - Andi'),
  ExpenseAdmin(id: 'exp-admin-budi', name: 'Kasir - Budi'),
  ExpenseAdmin(id: 'exp-admin-siti', name: 'Kasir - Siti'),
];

ExpenseAdmin get dummyCurrentExpenseAdmin {
  return dummyExpenseAdmins.firstWhere((admin) => admin.isCurrentUser);
}

List<Expense> initialDummyExpenses() => [
      Expense(
        id: 'exp-001',
        category: ExpenseCategory.beliGas,
        amount: 500000,
        adminName: 'Kasir - Andi',
        dateTime: DateTime(2026, 8, 7, 9, 15),
      ),
      Expense(
        id: 'exp-002',
        category: ExpenseCategory.bayarListrik,
        amount: 350000,
        adminName: 'Owner',
        dateTime: DateTime(2026, 8, 7, 11, 30),
      ),
      Expense(
        id: 'exp-003',
        category: ExpenseCategory.beliRinso,
        amount: 250000,
        adminName: 'Kasir - Budi',
        dateTime: DateTime(2026, 8, 7, 14, 35),
      ),
      Expense(
        id: 'exp-004',
        category: ExpenseCategory.transportKurir,
        amount: 150000,
        adminName: 'Kasir - Siti',
        dateTime: DateTime(2026, 8, 7, 16, 0),
      ),
      Expense(
        id: 'exp-005',
        category: ExpenseCategory.pengeluaranSampah,
        amount: 75000,
        adminName: 'Kasir - Andi',
        dateTime: DateTime(2026, 8, 5, 10, 0),
      ),
      Expense(
        id: 'exp-006',
        category: ExpenseCategory.atk,
        amount: 120000,
        adminName: 'Owner',
        dateTime: DateTime(2026, 7, 28, 13, 45),
      ),
      Expense(
        id: 'exp-007',
        category: ExpenseCategory.lainnya,
        amount: 85000,
        adminName: 'Kasir - Budi',
        dateTime: DateTime(2026, 8, 7, 8, 45),
        description: 'Bayar WiFi',
      ),
    ];

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isSameWeek(DateTime date, DateTime reference) {
  final startOfWeek = reference.subtract(Duration(days: reference.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  final normalized = DateTime(date.year, date.month, date.day);
  final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
  return !normalized.isBefore(start) && !normalized.isAfter(end);
}

bool _isSameMonth(DateTime date, DateTime reference) {
  return date.year == reference.year && date.month == reference.month;
}

List<Expense> filterExpenses({
  required List<Expense> expenses,
  required String query,
  required ExpensePeriodFilter period,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final now = DateTime.now();

  return expenses.where((expense) {
    final matchesSearch = normalizedQuery.isEmpty ||
        expense.category.label.toLowerCase().contains(normalizedQuery) ||
        (expense.description?.toLowerCase().contains(normalizedQuery) ?? false);

    if (!matchesSearch) {
      return false;
    }

    return switch (period) {
      ExpensePeriodFilter.today => _isSameDay(expense.dateTime, now),
      ExpensePeriodFilter.thisWeek => _isSameWeek(expense.dateTime, now),
      ExpensePeriodFilter.thisMonth => _isSameMonth(expense.dateTime, now),
    };
  }).toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}

int totalExpensesToday(List<Expense> expenses) {
  final now = DateTime.now();
  return expenses
      .where((expense) => _isSameDay(expense.dateTime, now))
      .fold<int>(0, (sum, expense) => sum + expense.amount);
}

String nextExpenseId(List<Expense> expenses) {
  final nextNumber = expenses.length + 1;
  return 'exp-${nextNumber.toString().padLeft(3, '0')}';
}
