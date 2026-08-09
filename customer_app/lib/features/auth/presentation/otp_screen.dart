import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.purpose,
    required this.otpRequestId,
  });

  final String phone;
  final String purpose;
  final String otpRequestId;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() => _loading = true);
    try {
      final rememberMe = await ref.read(preferencesProvider).getRememberMe();

      if (widget.purpose == 'register') {
        final uri = GoRouterState.of(context).uri;
        final name = uri.queryParameters['name'] ?? '';
        final email = uri.queryParameters['email'];
        final session = await ref.read(authRepositoryProvider).register(
              otpRequestId: widget.otpRequestId,
              phone: widget.phone,
              otpCode: otp,
              fullName: name,
              email: email?.isNotEmpty == true ? email : null,
              rememberMe: rememberMe,
            );
        await ref.read(authProvider.notifier).completeAuth(session);
      } else {
        final session = await ref.read(authRepositoryProvider).verifyOtp(
              otpRequestId: widget.otpRequestId,
              phone: widget.phone,
              otpCode: otp,
              rememberMe: rememberMe,
            );
        await ref.read(authProvider.notifier).completeAuth(session);
      }

      if (mounted) context.go('/home');
    } catch (error) {
      final message = error is ApiException ? error.message : 'OTP tidak valid';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kode OTP dikirim ke ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Kode OTP 6 digit'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading ? const CircularProgressIndicator() : const Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
