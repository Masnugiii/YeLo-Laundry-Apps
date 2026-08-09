import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/expenses/data/dummy_expenses.dart';
import 'package:yelo_laundry_erp/features/expenses/models/expense.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/expense_theme.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_sheet_widgets.dart';

void showAddExpenseBottomSheet(
  BuildContext context, {
  required ValueChanged<Expense> onSaved,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: Color(0x33033B8E),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      child: _AddExpenseBottomSheet(onSaved: onSaved),
    ),
  );
}

class _AddExpenseBottomSheet extends StatefulWidget {
  const _AddExpenseBottomSheet({required this.onSaved});

  final ValueChanged<Expense> onSaved;

  @override
  State<_AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<_AddExpenseBottomSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.pengeluaranSampah;
  ExpenseAdmin _selectedAdmin = dummyCurrentExpenseAdmin;
  late final DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$day ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  void _save() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    final description = _selectedCategory == ExpenseCategory.lainnya
        ? _descriptionController.text.trim()
        : null;

    final expense = Expense(
      id: 'exp-new-${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      amount: amount,
      adminName: _selectedAdmin.name,
      dateTime: _dateTime,
      description:
          description == null || description.isEmpty ? null : description,
    );

    widget.onSaved(expense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isLainnya = _selectedCategory == ExpenseCategory.lainnya;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const WalletSheetHandle(),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Tambahkan Pengeluaran',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            DropdownMenu<ExpenseCategory>(
              key: ValueKey(_selectedCategory),
              width: MediaQuery.sizeOf(context).width - 40,
              initialSelection: _selectedCategory,
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              label: Text(
                'Kategori Pengeluaran',
                style: ExpenseTheme.labelStyle(),
              ),
              dropdownMenuEntries: [
                for (final category in ExpenseCategory.values)
                  DropdownMenuEntry(
                    value: category,
                    label: category.label,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return ExpenseTheme.categoryColor;
                      }),
                      textStyle: WidgetStateProperty.all(
                        GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
              onSelected: (category) {
                if (category != null) {
                  setState(() {
                    if (category != ExpenseCategory.lainnya) {
                      _descriptionController.clear();
                    }
                    _selectedCategory = category;
                  });
                }
              },
              inputDecorationTheme: ExpenseTheme.dropdownDecorationTheme(),
            ),
            if (isLainnya) ...[
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Keterangan Pengeluaran',
                style: ExpenseTheme.labelStyle(),
              ),
              const SizedBox(height: AppSpacing.s8),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                cursorColor: AppColors.primary,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: ExpenseTheme.categoryColor,
                ),
                decoration: ExpenseTheme.outlinedDecoration(
                  hintText:
                      'Contoh: Bayar WiFi, Servis AC, Beli Ember, Beli Pewangi, Servis Mesin Cuci, Pembelian Lainnya',
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                  focusedBorderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Nominal Pengeluaran',
              style: ExpenseTheme.labelStyle(),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: AppColors.primary,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: ExpenseTheme.categoryColor,
              ),
              decoration: ExpenseTheme.outlinedDecoration(
                hintText: '50000',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            DropdownMenu<ExpenseAdmin>(
              key: ValueKey(_selectedAdmin.id),
              width: MediaQuery.sizeOf(context).width - 40,
              initialSelection: _selectedAdmin,
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              label: Text(
                'Admin yang Bertanggung Jawab',
                style: ExpenseTheme.labelStyle(),
              ),
              dropdownMenuEntries: [
                for (final admin in dummyExpenseAdmins)
                  DropdownMenuEntry(
                    value: admin,
                    label: admin.name,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return ExpenseTheme.categoryColor;
                      }),
                      textStyle: WidgetStateProperty.all(
                        GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
              onSelected: (admin) {
                if (admin != null) {
                  setState(() => _selectedAdmin = admin);
                }
              },
              inputDecorationTheme: ExpenseTheme.dropdownDecorationTheme(),
            ),
            const SizedBox(height: AppSpacing.s16),
            _ReadOnlyField(label: 'Tanggal', value: _formatDate(_dateTime)),
            const SizedBox(height: AppSpacing.s12),
            _ReadOnlyField(label: 'Jam', value: _formatTime(_dateTime)),
            const SizedBox(height: AppSpacing.s24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Simpan Pengeluaran',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ExpenseTheme.labelStyle(),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          decoration: BoxDecoration(
            color: AppColors.dashboardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            value,
            style: ExpenseTheme.valueStyle(
              fontSize: 15,
              color: ExpenseTheme.metaColor,
            ),
          ),
        ),
      ],
    );
  }
}
