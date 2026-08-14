import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/auth_screen_styles.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/dev_preview_entry_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    final validationError = PhoneUtil.validate(rawPhone);
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    final phone = PhoneUtil.normalizeForApi(rawPhone);

    setState(() => _loading = true);
    try {
      await ref.read(preferencesProvider).setRememberMe(_rememberMe);
      final result = await ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            purpose: 'login',
          );
      if (!mounted) return;
      context.push(
        '/otp?phone=${Uri.encodeComponent(phone)}'
        '&purpose=login'
        '&otpRequestId=${Uri.encodeComponent(result.otpRequestId)}'
        '&maskedPhone=${Uri.encodeComponent(result.maskedPhone)}',
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
      if (message.contains('not found') || message.contains('tidak ditemukan')) {
        return 'Nomor WhatsApp belum terdaftar. Silakan daftar terlebih dahulu.';
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s24,
                AppSpacing.s24,
                AppSpacing.s24 + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.s16),
                    Center(
                      child: Image.asset(
                        AuthScreenStyles.logoAsset,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Selamat Datang, Yelo ',
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
                              color: const Color(0xFFFFFF00),
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
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _loading ? null : _sendOtp(),
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
                          const SizedBox(height: AppSpacing.s24),
                          FilledButton(
                            onPressed: _loading ? null : _sendOtp,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF4E900),
                              disabledBackgroundColor:
                                  const Color(0xFFF4E900).withValues(alpha: 0.6),
                              minimumSize: const Size.fromHeight(
                                AuthScreenStyles.primaryButtonHeight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brandBlue,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: AuthScreenStyles.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brandBlue,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: AuthScreenStyles.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Daftar',
                            style: AuthScreenStyles.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    const DevPreviewEntryButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
