import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';

class RoleCheckScreen extends ConsumerStatefulWidget {
  const RoleCheckScreen({super.key});

  @override
  ConsumerState<RoleCheckScreen> createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends ConsumerState<RoleCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToDashboard());
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    final role = ref.read(sessionProvider).role;
    context.go(role.dashboardRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Memuat dashboard...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
