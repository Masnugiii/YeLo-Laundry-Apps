import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_form_field.dart';

Future<void> showAddCustomerBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _AddCustomerBottomSheet(),
  );
}

class _AddCustomerBottomSheet extends ConsumerStatefulWidget {
  const _AddCustomerBottomSheet();

  @override
  ConsumerState<_AddCustomerBottomSheet> createState() =>
      _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState extends ConsumerState<_AddCustomerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final DateTime _joinDate = DateTime(2026, 8, 7);
  late final TextEditingController _joinDateController;

  bool _isSaving = false;

  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.divider),
  );

  @override
  void initState() {
    super.initState();
    _joinDateController = TextEditingController(
      text: _formatJoinDate(_joinDate),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  String _formatJoinDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final customer =
          await ref.read(customerRepositoryProvider).createCustomer(
                fullName: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                occupation: _occupationController.text.trim(),
                addressDetail: _addressController.text.trim(),
              );

      if (!mounted) return;

      Navigator.of(context).pop(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pelanggan ${customer.name} berhasil disimpan',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message, style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan pelanggan.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Tambah Customer Baru',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
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
              const SizedBox(height: AppSpacing.s16),
              CustomerFormField(
                label: 'Nomor HP',
                isRequired: true,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: _decoration('08xxxxxxxxxx'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nomor HP wajib diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              CustomerFormField(
                label: 'Pekerjaan',
                child: TextFormField(
                  controller: _occupationController,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: _decoration('Masukkan pekerjaan'),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              CustomerFormField(
                label: 'Alamat Rumah',
                child: TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: _decoration('Masukkan alamat rumah'),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              CustomerFormField(
                label: 'Tanggal Bergabung',
                child: TextFormField(
                  readOnly: true,
                  enabled: false,
                  controller: _joinDateController,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _decoration('').copyWith(
                    filled: true,
                    fillColor: AppColors.dashboardBackground,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          'Simpan Customer',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
