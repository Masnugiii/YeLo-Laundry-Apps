import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    if (phone.isEmpty || name.isEmpty) return;

    setState(() => _loading = true);
    try {
      final result = await ref.read(authRepositoryProvider).sendOtp(
            phone: phone,
            purpose: 'register',
          );
      if (!mounted) return;
      context.push(
        '/otp?phone=$phone&purpose=register&otpRequestId=${result.otpRequestId}&name=${Uri.encodeComponent(name)}&email=${Uri.encodeComponent(_emailController.text.trim())}',
      );
    } catch (error) {
      final message = error is ApiException ? error.message : 'Gagal mengirim OTP';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Lengkap'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Nomor HP'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (opsional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Kirim OTP'),
          ),
        ],
      ),
    );
  }
}
