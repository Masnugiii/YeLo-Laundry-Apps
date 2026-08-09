import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/data/dummy_occupations.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_form_field.dart';
import 'package:yelo_laundry_erp/features/customer/utils/phone_validator.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final ValueChanged<CustomerFormData> onSubmit;

  @override
  State<CustomerForm> createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedOccupation;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.divider),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void submit() {
    if (!(widget.formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      CustomerFormData(
        name: _nameController.text.trim(),
        phone: normalizeIndonesianPhone(_phoneController.text.trim()),
        occupation: _selectedOccupation,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: CustomerFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerFormField(
              label: 'Nama Pelanggan',
              isRequired: true,
              child: TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: _decoration('Masukkan nama pelanggan'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pelanggan wajib diisi';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            CustomerFormField(
              label: 'Nomor HP',
              isRequired: true,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                ],
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: _decoration('08xx xxxx xxxx'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  if (!isValidIndonesianPhone(value.trim())) {
                    return 'Masukkan nomor HP Indonesia yang valid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            CustomerFormField(
              label: 'Pekerjaan',
              child: DropdownButtonFormField<String>(
                initialValue: _selectedOccupation,
                decoration: _decoration('Pilih pekerjaan'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                items: dummyOccupations
                    .map(
                      (occupation) => DropdownMenuItem(
                        value: occupation,
                        child: Text(occupation),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedOccupation = value);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            CustomerFormField(
              label: 'Alamat Rumah',
              child: TextFormField(
                controller: _addressController,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: _decoration('Masukkan alamat rumah (opsional)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.dashboardBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s16,
      ),
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: _inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: _inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}
