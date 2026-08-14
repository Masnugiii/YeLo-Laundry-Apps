import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/staff/providers/staff_admin_provider.dart';
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

const _categoryCodeMap = <ExpenseCategory, String>{
  ExpenseCategory.pengeluaranSampah: 'OTHER',
  ExpenseCategory.beliGas: 'LAUNDRY_SUPPLIES',
  ExpenseCategory.beliGalon: 'WATER',
  ExpenseCategory.bayarListrik: 'ELECTRICITY',
  ExpenseCategory.beliRinso: 'LAUNDRY_SUPPLIES',
  ExpenseCategory.beliPlastik: 'LAUNDRY_SUPPLIES',
  ExpenseCategory.jasaCleaningYelo: 'MAINTENANCE',
  ExpenseCategory.transportKurir: 'TRANSPORTATION',
  ExpenseCategory.atk: 'OTHER',
  ExpenseCategory.perawatanMesin: 'MAINTENANCE',
  ExpenseCategory.lainnya: 'OTHER',
};

class _AddExpenseBottomSheet extends ConsumerStatefulWidget {
  const _AddExpenseBottomSheet({required this.onSaved});

  final ValueChanged<Expense> onSaved;

  @override
  ConsumerState<_AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<_AddExpenseBottomSheet> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.pengeluaranSampah;
  ExpenseAdmin? _selectedAdmin;
  late final DateTime _dateTime;
  bool _isSaving = false;

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

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _isSaving) {
      return;
    }

    final description = _selectedCategory == ExpenseCategory.lainnya
        ? _descriptionController.text.trim()
        : null;

    setState(() => _isSaving = true);

    try {
      final response = await ref.read(financeRepositoryProvider).createExpense({
        'categoryCode': _categoryCodeMap[_selectedCategory] ?? 'OTHER',
        'title': _selectedCategory.label,
        if (description != null && description.isNotEmpty)
          'description': description,
        'amount': amount,
        'expenseDate': _dateTime.toIso8601String(),
      });

      final expense = Expense(
        id: response['id'] as String? ?? '',
        category: _selectedCategory,
        amount: amount,
        adminName: _selectedAdmin?.name ?? 'Staff',
        dateTime: _dateTime,
        description:
            description == null || description.isEmpty ? null : description,
      );

      if (!mounted) return;
      widget.onSaved(expense);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan pengeluaran.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isLainnya = _selectedCategory == ExpenseCategory.lainnya;
    final adminsAsync = ref.watch(expenseAdminOptionsProvider);

    return adminsAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s12,
          AppSpacing.s20,
          AppSpacing.s20 + bottomInset,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s12,
          AppSpacing.s20,
          AppSpacing.s20 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WalletSheetHandle(),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Gagal memuat daftar admin.',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.s12),
            FilledButton(
              onPressed: () => ref.invalidate(expenseAdminOptionsProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (admins) {
        final selectedAdmin =
            _selectedAdmin ?? currentExpenseAdmin(admins);
        if (_selectedAdmin == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedAdmin = selectedAdmin);
          });
        }

        return _buildForm(
          context,
          bottomInset: bottomInset,
          isLainnya: isLainnya,
          admins: admins,
          selectedAdmin: selectedAdmin,
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context, {
    required double bottomInset,
    required bool isLainnya,
    required List<ExpenseAdmin> admins,
    required ExpenseAdmin selectedAdmin,
  }) {
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
              key: ValueKey(selectedAdmin.id),
              width: MediaQuery.sizeOf(context).width - 40,
              initialSelection: selectedAdmin,
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
                for (final admin in admins)
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
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Pengeluaran',
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
