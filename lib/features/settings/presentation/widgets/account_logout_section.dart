import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class AccountLogoutSection extends ConsumerWidget {
  const AccountLogoutSection({super.key});

  Future<void> _onLogoutPressed(BuildContext context, WidgetRef ref) async {
    final confirmed = await showLogoutConfirmationDialog(context);
    if (confirmed != true || !context.mounted) return;

    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionCard(
      title: 'AKUN',
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
          ),
          leading: const Icon(
            Icons.logout,
            color: AppColors.error,
          ),
          title: Text(
            'Keluar',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          onTap: () => _onLogoutPressed(context, ref),
        ),
      ],
    );
  }
}
