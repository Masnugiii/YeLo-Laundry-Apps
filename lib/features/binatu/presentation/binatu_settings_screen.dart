import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/account_logout_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class BinatuSettingsScreen extends StatefulWidget {
  const BinatuSettingsScreen({
    super.key,
    this.showBackButton = false,
    this.showBackToDashboard = false,
  });

  final bool showBackButton;
  final bool showBackToDashboard;

  @override
  State<BinatuSettingsScreen> createState() => _BinatuSettingsScreenState();
}

class _BinatuSettingsScreenState extends State<BinatuSettingsScreen> {
  AppSettingsState _settings = initialAppSettings;

  void _updateSettings(AppSettingsState settings) {
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading:
            widget.showBackButton && !widget.showBackToDashboard,
        leading: widget.showBackToDashboard
            ? const DashboardAppBarBackButton()
            : null,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          widget.showBackToDashboard ? 'Akun' : 'Settings',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
          SettingsSectionCard(
            title: 'NOTIFICATION CENTER',
            children: [
              SettingsNavigationTile(
                title: 'Lihat Semua Notifikasi',
                onTap: () => context.push('/notifications'),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          NotificationSettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          const AccountLogoutSection(),
        ],
      ),
    );
  }
}
