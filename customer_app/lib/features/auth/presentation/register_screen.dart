import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/auth_screen_styles.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const _minAge = 13;
  static const _maxAge = 100;
  static const _maxOccupationLength = 100;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  String? _validateAge(String value) {
    if (value.isEmpty) return 'Umur wajib diisi';
    final age = int.tryParse(value);
    if (age == null) return 'Umur harus berupa angka';
    if (age < _minAge || age > _maxAge) {
      return 'Umur harus antara $_minAge dan $_maxAge tahun';
    }
    return null;
  }

  String? _validateOccupation(String value) {
    if (value.isEmpty) return 'Pekerjaan wajib diisi';
    if (value.length > _maxOccupationLength) {
      return 'Pekerjaan maksimal $_maxOccupationLength karakter';
    }
    return null;
  }

  Future<void> _sendOtp() async {
    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();
    final ageText = _ageController.text.trim();
    final occupation = _occupationController.text.trim();

    if (name.isEmpty) {
      _showError('Nama lengkap wajib diisi');
      return;
    }

    final phoneError = PhoneUtil.validate(rawPhone);
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    final ageError = _validateAge(ageText);
    if (ageError != null) {
      _showError(ageError);
      return;
    }

    final occupationError = _validateOccupation(occupation);
    if (occupationError != null) {
      _showError(occupationError);
      return;
    }

    final phone = PhoneUtil.normalizeForApi(rawPhone);
    final age = int.parse(ageText);

    setState(() => _loading = true);
    try {
      final result = await ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            purpose: 'register',
          );
      if (!mounted) return;
      context.push(
        '/otp?phone=${Uri.encodeComponent(phone)}'
        '&purpose=register'
        '&otpRequestId=${Uri.encodeComponent(result.otpRequestId)}'
        '&maskedPhone=${Uri.encodeComponent(result.maskedPhone)}'
        '&name=${Uri.encodeComponent(name)}'
        '&age=$age'
        '&occupation=${Uri.encodeComponent(occupation)}',
      );
    } catch (error) {
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();
      if (message.contains('already') || message.contains('sudah')) {
        return 'Nomor WhatsApp sudah terdaftar. Silakan masuk.';
      }
      return error.message;
    }
    return 'Gagal mengirim kode. Periksa koneksi internet lalu coba lagi.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.brandBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daftar',
          style: AuthScreenStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s24,
            0,
            AppSpacing.s24,
            AppSpacing.s24 + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  AuthScreenStyles.logoAsset,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Daftar sebagai Yelo ',
                      style: AuthScreenStyles.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'People!',
                      style: AuthScreenStyles.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AuthScreenStyles.peopleHighlightColor,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s32),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: AuthScreenStyles.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      style: AuthScreenStyles.poppins(
                        fontSize: AuthScreenStyles.inputFontSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: AuthScreenStyles.inputDecoration(
                        labelText: 'Nama lengkap',
                        hintText: 'Masukkan nama lengkap',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: AuthScreenStyles.poppins(
                        fontSize: AuthScreenStyles.inputFontSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: AuthScreenStyles.inputDecoration(
                        labelText: 'Nomor WhatsApp',
                        hintText: 'Masukkan nomor WhatsApp',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.s8,
                        left: AppSpacing.s4,
                      ),
                      child: Text(
                        'Contoh: 081234567890',
                        style: AuthScreenStyles.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AuthScreenStyles.poppins(
                        fontSize: AuthScreenStyles.inputFontSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: AuthScreenStyles.inputDecoration(
                        labelText: 'Umur',
                        hintText: 'Masukkan umur',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    TextField(
                      controller: _occupationController,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: _maxOccupationLength,
                      onSubmitted: (_) => _loading ? null : _sendOtp(),
                      style: AuthScreenStyles.poppins(
                        fontSize: AuthScreenStyles.inputFontSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: AuthScreenStyles.inputDecoration(
                        labelText: 'Pekerjaan saat ini',
                        hintText: 'Contoh: Ibu Rumah Tangga',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    FilledButton(
                      onPressed: _loading ? null : _sendOtp,
                      style: AuthScreenStyles.primaryButtonStyle(),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Daftar',
                              style: AuthScreenStyles.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: AuthScreenStyles.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Masuk',
                      style: AuthScreenStyles.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
