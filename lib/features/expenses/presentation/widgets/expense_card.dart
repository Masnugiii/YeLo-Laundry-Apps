import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/expense_theme.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
  });

  final Expense expense;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final isLainnya = expense.category == ExpenseCategory.lainnya;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: ClipRRect(
        borderRadius: _cardRadius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoField(
                        label: 'Kategori Pengeluaran',
                        value: expense.category.label,
                        valueStyle: ExpenseTheme.valueStyle(
                          fontWeight: FontWeight.w600,
                          color: ExpenseTheme.categoryColor,
                        ),
                      ),
                      if (isLainnya &&
                          expense.description != null &&
                          expense.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          'Keterangan Pengeluaran',
                          style: ExpenseTheme.labelStyle(fontSize: 12),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            expense.description!,
                            style: ExpenseTheme.valueStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ExpenseTheme.categoryColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Nominal',
                        value: formatRupiah(expense.amount),
                        valueStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Admin',
                        value: expense.adminName,
                        valueStyle: ExpenseTheme.valueStyle(
                          color: ExpenseTheme.categoryColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Tanggal',
                        value: expense.formattedDate,
                        valueStyle: ExpenseTheme.valueStyle(
                          color: ExpenseTheme.metaColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Jam',
                        value: expense.formattedTime,
                        valueStyle: ExpenseTheme.valueStyle(
                          color: ExpenseTheme.metaColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ExpenseTheme.labelStyle(fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: valueStyle ??
              ExpenseTheme.valueStyle(
                fontWeight: FontWeight.w600,
                color: ExpenseTheme.categoryColor,
              ),
        ),
      ],
    );
  }
}
