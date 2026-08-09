import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';
import 'package:yelo_laundry_erp/features/employee_master/providers/employee_providers.dart';

void showAddEmployeeBottomSheet(
  BuildContext context, {
  required WidgetRef ref,
  required VoidCallback onSaved,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _AddEmployeeBottomSheet(
      ref: ref,
      onSaved: onSaved,
    ),
  );
}

class _AddEmployeeBottomSheet extends ConsumerStatefulWidget {
  const _AddEmployeeBottomSheet({
    required this.ref,
    required this.onSaved,
  });

  final WidgetRef ref;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AddEmployeeBottomSheet> createState() =>
      _AddEmployeeBottomSheetState();
}

class _AddEmployeeBottomSheetState
    extends ConsumerState<_AddEmployeeBottomSheet> {
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  EmployeeRole _role = EmployeeRole.kasir;
  EmployeeStatus _status = EmployeeStatus.active;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestedCode();
  }

  Future<void> _loadSuggestedCode() async {
    try {
      final code = await ref.read(suggestedEmployeeCodeProvider.future);
      if (!mounted) return;
      _employeeIdController.text = code;
      setState(() {});
    } catch (_) {
      // Keep field empty if numbering config is unavailable.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final employeeCode = _employeeIdController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.length < 6 || employeeCode.isEmpty) {
      setState(() => _error = 'Lengkapi nama, telepon, password (min 6), dan kode karyawan.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(employeeRepositoryProvider).createEmployee(
            employeeCode: employeeCode,
            fullName: name,
            phone: phone,
            password: password,
            position: _role.label,
            status: _status == EmployeeStatus.active ? 'ACTIVE' : 'INACTIVE',
          );

      if (!mounted) return;
      widget.onSaved();
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: EmployeeMasterTheme.labelStyle,
        filled: true,
        fillColor: AppColors.dashboardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tambah Karyawan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            TextField(
              controller: _nameController,
              decoration: _fieldDecoration('Full Name'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _employeeIdController,
              decoration: _fieldDecoration('Employee Code'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration('Phone Number'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _fieldDecoration('Password'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: _fieldDecoration('Address (opsional)'),
            ),
            const SizedBox(height: AppSpacing.s12),
            DropdownButtonFormField<EmployeeRole>(
              initialValue: _role,
              decoration: _fieldDecoration('Role'),
              items: [
                for (final role in [
                  EmployeeRole.kasir,
                  EmployeeRole.binatu,
                  EmployeeRole.manager,
                ])
                  DropdownMenuItem(
                    value: role,
                    child: Text(role.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _role = value);
              },
            ),
            const SizedBox(height: AppSpacing.s12),
            DropdownButtonFormField<EmployeeStatus>(
              initialValue: _status,
              decoration: _fieldDecoration('Status'),
              items: [
                for (final status in EmployeeStatus.values)
                  DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                _error!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _saving ? 'Menyimpan...' : 'Save Employee',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
