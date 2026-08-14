import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/ironing_queue_priority_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/system_config_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/laundry_profile_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/order_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/reminder_recipient_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/security_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/service_reminder_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/account_logout_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/whatsapp_reminder_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.showBackButton = true,
    this.showBackToDashboard = false,
  });

  final bool showBackButton;
  final bool showBackToDashboard;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          const SystemConfigSettingsSection(),
          const SizedBox(height: AppSpacing.s16),
          const LaundryProfileSettingsSection(),
          const SizedBox(height: AppSpacing.s16),
          NotificationSettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          MaintenanceSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          ReminderRecipientSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          WhatsappReminderSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          SystemSettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          OrderSettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          const IroningQueuePrioritySettingsSection(),
          const SizedBox(height: AppSpacing.s16),
          CustomerSettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          PickupDeliverySettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          SecuritySettingsSection(
            settings: _settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: AppSpacing.s16),
          const AboutSettingsSection(aboutInfo: defaultAppAboutInfo),
          const SizedBox(height: AppSpacing.s16),
          const AccountLogoutSection(),
        ],
      ),
    );
  }
}
