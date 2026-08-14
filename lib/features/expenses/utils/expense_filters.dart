import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';

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
