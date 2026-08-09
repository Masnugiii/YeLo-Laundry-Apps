import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/widgets/auth_page_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _laundryNameController = TextEditingController();
  final _ownerNameController = TextEditingController();

  @override
  void dispose() {
    _laundryNameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    context.go('/role-check');
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      showVersion: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daftar Laundry',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Lengkapi data singkat untuk mulai menggunakan Yelo Laundry.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          TextField(
            controller: _laundryNameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama Laundry',
              hintText: 'Contoh: Yelo Laundry Ciputat',
              prefixIcon: Icon(Icons.local_laundry_service_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: _ownerNameController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onStartPressed(),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama Pemilik',
              hintText: 'Contoh: Budi Santoso',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onStartPressed,
              child: Text(
                'Mulai Menggunakan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
