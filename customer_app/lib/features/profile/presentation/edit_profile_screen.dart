import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _photoController = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _initialize(CustomerSession session) {
    if (_initialized) return;
    _nameController.text = session.fullName;
    _emailController.text = session.email ?? '';
    _photoController.text = session.photoUrl ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final session = await ref.read(profileRepositoryProvider).updateProfile(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            photoUrl: _photoController.text.trim().isEmpty
                ? null
                : _photoController.text.trim(),
          );
      await ref.read(authProvider.notifier).completeAuth(session);
      if (mounted) context.pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    _initialize(session);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 12),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _photoController, decoration: const InputDecoration(labelText: 'URL Avatar')),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading ? const CircularProgressIndicator() : const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
