import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/widgets/otp_input_widget.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.isLoginFlow = false,
  });

  final String phoneNumber;
  final bool isLoginFlow;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _initialSeconds = 60;

  Timer? _timer;
  int _remainingSeconds = _initialSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _initialSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }

      setState(() => _remainingSeconds -= 1);
    });
  }

  String get _maskedPhoneNumber {
    final phone = widget.phoneNumber.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8) {
      return phone.isEmpty ? '+62 812••••7890' : phone;
    }

    final prefix = digits.substring(0, digits.length >= 5 ? 5 : digits.length);
    final suffix = digits.substring(digits.length - 4);
    final countryCode = phone.startsWith('+') ? '+' : '';

    if (phone.contains(' ')) {
      final parts = phone.split(' ');
      if (parts.length >= 2) {
        return '${parts.first} ${parts[1]}••••$suffix';
      }
    }

    return '$countryCode$prefix••••$suffix';
  }

  String get _formattedCountdown {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onVerifyPressed() {
    if (widget.isLoginFlow) {
      context.go('/role-check');
      return;
    }

    context.go('/register');
  }

  void _onResendPressed() {
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      showVersion: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verifikasi Nomor',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Kami telah mengirim kode OTP ke nomor WhatsApp Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            _maskedPhoneNumber,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          const OtpInputWidget(),
          const SizedBox(height: AppSpacing.s24),
          Text(
            _formattedCountdown,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onVerifyPressed,
              child: Text(
                'Verifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          TextButton(
            onPressed: _onResendPressed,
            child: Text(
              'Kirim Ulang Kode',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
