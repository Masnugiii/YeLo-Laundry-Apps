import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/expenses/data/dummy_expenses.dart';
import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/expense_theme.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/widgets/expense_card.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/widgets/expense_summary_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _filters = ExpensePeriodFilter.values;

  final _searchController = TextEditingController();
  late List<Expense> _expenses;
  ExpensePeriodFilter _selectedFilter = ExpensePeriodFilter.today;

  @override
  void initState() {
    super.initState();
    _expenses = initialDummyExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses = [expense, ..._expenses];
    });
  }

  List<Expense> get _filteredExpenses => filterExpenses(
        expenses: _expenses,
        query: _searchController.text,
        period: _selectedFilter,
      );

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    final totalToday = totalExpensesToday(_expenses);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Pengeluaran',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => showAddExpenseBottomSheet(
                  context,
                  onSaved: _addExpense,
                ),
                icon: const Icon(Icons.add, color: AppColors.onPrimary),
                label: Text(
                  'Tambahkan Pengeluaran',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              0,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: ExpenseSummaryCard(totalToday: totalToday),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              0,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              cursorColor: AppColors.primary,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: ExpenseTheme.categoryColor,
              ),
              decoration: ExpenseTheme.outlinedDecoration(
                hintText: 'Cari kategori pengeluaran',
              ).copyWith(
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return SelectableChip(
                  label: filter.label,
                  isSelected: isSelected,
                  selectedBackgroundColor: AppColors.accent,
                  selectedTextColor: AppColors.primary,
                  onTap: () => setState(() => _selectedFilter = filter),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada pengeluaran',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      0,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseCard(expense: filteredExpenses[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
