import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_master/models/employee.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_theme.dart';

void showAddEmployeeBottomSheet(
  BuildContext context, {
  required ValueChanged<Employee> onSaved,
  required int nextEmployeeNumber,
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
      onSaved: onSaved,
      nextEmployeeNumber: nextEmployeeNumber,
    ),
  );
}

class _AddEmployeeBottomSheet extends StatefulWidget {
  const _AddEmployeeBottomSheet({
    required this.onSaved,
    required this.nextEmployeeNumber,
  });

  final ValueChanged<Employee> onSaved;
  final int nextEmployeeNumber;

  @override
  State<_AddEmployeeBottomSheet> createState() =>
      _AddEmployeeBottomSheetState();
}

class _AddEmployeeBottomSheetState extends State<_AddEmployeeBottomSheet> {
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  EmployeeGender _gender = EmployeeGender.male;
  EmployeeRole _role = EmployeeRole.kasir;
  EmployeeStatus _status = EmployeeStatus.active;
  final DateTime _birthDate = DateTime(1995, 1, 1);
  final DateTime _joinDate = DateTime(2026, 8, 7);

  @override
  void initState() {
    super.initState();
    _employeeIdController.text =
        'EMP-${widget.nextEmployeeNumber.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final employee = Employee(
      id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
      employeeCode: _employeeIdController.text.trim(),
      fullName: name,
      initials: _initialsFromName(name),
      role: _role,
      status: _status,
      phone: _phoneController.text.trim().isEmpty
          ? '08xxxxxxxxxx'
          : _phoneController.text.trim(),
      gender: _gender,
      dateOfBirth: _birthDate,
      address: _addressController.text.trim().isEmpty
          ? '-'
          : _addressController.text.trim(),
      joinDate: _joinDate,
      emergencyContact: '-',
      branch: 'Yelo Laundry Pusat',
      position: _role.label,
    );

    widget.onSaved(employee);
    Navigator.pop(context);
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
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Center(
              child: Text('Photo', style: EmployeeMasterTheme.labelStyle),
            ),
            const SizedBox(height: AppSpacing.s20),
            TextField(
              controller: _nameController,
              decoration: _fieldDecoration('Full Name'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _employeeIdController,
              decoration: _fieldDecoration('Employee ID'),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration('Phone Number'),
            ),
            const SizedBox(height: AppSpacing.s12),
            DropdownButtonFormField<EmployeeGender>(
              initialValue: _gender,
              decoration: _fieldDecoration('Gender'),
              items: [
                for (final gender in EmployeeGender.values)
                  DropdownMenuItem(
                    value: gender,
                    child: Text(gender.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _gender = value);
              },
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: formatEmployeeDate(_birthDate),
              ),
              decoration: _fieldDecoration('Birth Date'),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: _fieldDecoration('Address'),
            ),
            const SizedBox(height: AppSpacing.s12),
            DropdownButtonFormField<EmployeeRole>(
              initialValue: _role,
              decoration: _fieldDecoration('Role'),
              items: [
                for (final role in EmployeeRole.values)
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
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: formatEmployeeDate(_joinDate),
              ),
              decoration: _fieldDecoration('Join Date'),
              onTap: () {},
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
            const SizedBox(height: AppSpacing.s24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Employee',
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
