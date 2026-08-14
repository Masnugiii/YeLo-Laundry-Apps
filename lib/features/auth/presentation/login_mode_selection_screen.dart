import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/auth/models/login_mode.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/widgets/login_mode_card.dart';

/// Development-only page for previewing operational modes without authentication.
class LoginModeSelectionScreen extends ConsumerStatefulWidget {
  const LoginModeSelectionScreen({super.key});

  @override
  ConsumerState<LoginModeSelectionScreen> createState() =>
      _LoginModeSelectionScreenState();
}

class _LoginModeSelectionScreenState
    extends ConsumerState<LoginModeSelectionScreen> {
  static const _modes = LoginMode.values;

  Future<void> _enterMode(LoginMode mode) async {
    try {
      await ref.read(authProvider.notifier).login(
            phone: mode.devPhone,
            password: LoginMode.devPassword,
          );
      // Router redirect sends authenticated users to /role-check, which routes
      // to the dashboard that matches the logged-in employee role.
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal login mode development. Pastikan backend berjalan dan seed data sudah dijalankan.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Pilih Mode Login',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Development Only',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Pilih perangkat atau mode kerja yang akan digunakan.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          for (var i = 0; i < _modes.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s16),
            LoginModeCard(
              mode: _modes[i],
              onPressed: isLoading ? () {} : () => _enterMode(_modes[i]),
            ),
          ],
        ],
      ),
    );
  }
}
