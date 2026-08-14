import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/auth_screen_styles.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.purpose,
    required this.otpRequestId,
    this.maskedPhone,
    this.name,
    this.age,
    this.occupation,
  });

  final String phone;
  final String purpose;
  final String otpRequestId;
  final String? maskedPhone;
  final String? name;
  final int? age;
  final String? occupation;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendCooldownSeconds = 60;

  final _otpController = TextEditingController();
  late String _otpRequestId;
  late String _maskedPhone;
  bool _loading = false;
  bool _resending = false;
  int _resendSeconds = _resendCooldownSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpRequestId = widget.otpRequestId;
    _maskedPhone = widget.maskedPhone ?? widget.phone;
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Masukkan kode 6 digit dari WhatsApp Anda');
      return;
    }

    setState(() => _loading = true);
    try {
      final rememberMe = await ref.read(preferencesProvider).getRememberMe();

      if (widget.purpose == 'register') {
        final name = widget.name?.trim() ?? '';
        final age = widget.age;
        final occupation = widget.occupation?.trim() ?? '';
        if (name.isEmpty || age == null || occupation.isEmpty) {
          _showError('Data pendaftaran tidak lengkap. Silakan daftar ulang.');
          return;
        }
        final session = await ref.read(authRepositoryProvider).register(
              otpRequestId: _otpRequestId,
              phone: widget.phone,
              otpCode: otp,
              fullName: name,
              age: age,
              occupation: occupation,
              rememberMe: rememberMe,
            );
        await ref.read(authProvider.notifier).completeAuth(session);
      } else if (widget.purpose == 'phone_change') {
        final session =
            await ref.read(profileRepositoryProvider).verifyPhoneChange(
                  phone: widget.phone,
                  otpRequestId: _otpRequestId,
                  otpCode: otp,
                );
        await ref.read(preferencesProvider).saveCustomerProfile(session);
        await ref.read(authProvider.notifier).refreshProfile();
        if (!mounted) return;
        FocusManager.instance.primaryFocus?.unfocus();
        context.go('/settings');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor WhatsApp berhasil diperbarui.')),
        );
        return;
      } else {
        final session = await ref.read(authRepositoryProvider).verifyOtp(
              otpRequestId: _otpRequestId,
              phone: widget.phone,
              otpCode: otp,
              rememberMe: rememberMe,
            );
        await ref.read(authProvider.notifier).completeAuth(session);
      }

      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      context.go('/home');
    } catch (error) {
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || _resending) return;

    setState(() => _resending = true);
    try {
      final result = await ref.read(authRepositoryProvider).sendOtp(
            phone: widget.phone,
            purpose: widget.purpose,
          );
      if (!mounted) return;
      setState(() {
        _otpRequestId = result.otpRequestId;
        _maskedPhone = result.maskedPhone;
        _otpController.clear();
      });
      _startResendCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode baru telah dikirim ke WhatsApp Anda'),
        ),
      );
    } catch (error) {
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid') || message.contains('tidak valid')) {
        return 'Kode salah. Periksa kembali pesan WhatsApp Anda.';
      }
      if (message.contains('expired') || message.contains('kadaluarsa')) {
        return 'Kode sudah kadaluarsa. Ketuk "Kirim ulang kode".';
      }
      return error.message;
    }
    return 'Verifikasi gagal. Coba lagi.';
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
          'Verifikasi WhatsApp',
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
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Kode verifikasi telah dikirim ke WhatsApp Anda',
                textAlign: TextAlign.center,
                style: AuthScreenStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _maskedPhone,
                textAlign: TextAlign.center,
                style: AuthScreenStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AuthScreenStyles.peopleHighlightColor,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: AuthScreenStyles.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (_) => _loading ? null : _verify(),
                      style: AuthScreenStyles.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Kode 6 digit',
                        labelStyle: AuthScreenStyles.poppins(
                          fontSize: AuthScreenStyles.inputFontSize,
                          color: AppColors.textSecondary,
                        ),
                        hintText: '000000',
                        hintStyle: AuthScreenStyles.poppins(
                          fontSize: 28,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                          letterSpacing: 8,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    FilledButton(
                      onPressed: _loading ? null : _verify,
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
                              'Verifikasi',
                              style: AuthScreenStyles.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    TextButton(
                      onPressed: (_resendSeconds > 0 || _resending) ? null : _resendOtp,
                      child: _resending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _resendSeconds > 0
                                  ? 'Kirim ulang kode ($_resendSeconds detik)'
                                  : 'Kirim ulang kode',
                              style: AuthScreenStyles.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _resendSeconds > 0
                                    ? AppColors.textSecondary
                                    : AppColors.brandBlue,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
