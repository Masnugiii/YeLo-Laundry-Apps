import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(preferencesProvider).setRememberMe(_rememberMe);
      final result = await ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            purpose: 'login',
          );
      if (!mounted) return;
      context.push(
        '/otp?phone=$phone&purpose=login&otpRequestId=${result.otpRequestId}',
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Gagal mengirim OTP. Coba lagi.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Selamat datang', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Masukkan nomor HP untuk menerima kode OTP.'),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              hintText: '081234567890',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          CheckboxListTile(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? true),
            title: const Text('Ingat saya'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kirim OTP'),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('Belum punya akun? Daftar'),
          ),
          TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: const Text('Lupa password / butuh bantuan login'),
          ),
        ],
      ),
    );
  }
}
