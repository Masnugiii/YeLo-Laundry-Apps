import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class SecuritySettingsSection extends StatelessWidget {
  const SecuritySettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'SECURITY',
      children: [
        SettingsSwitchTile(
          title: 'Login dengan OTP WhatsApp',
          value: settings.whatsappOtpLogin,
          onChanged: (value) =>
              onChanged(settings.copyWith(whatsappOtpLogin: value)),
        ),
        SettingsSwitchTile(
          title: 'Logout Otomatis',
          value: settings.autoLogout,
          onChanged: (value) => onChanged(settings.copyWith(autoLogout: value)),
        ),
        SettingsSwitchTile(
          title: 'PIN Owner untuk Menu Laporan',
          value: settings.ownerPinForReports,
          showDivider: false,
          onChanged: (value) =>
              onChanged(settings.copyWith(ownerPinForReports: value)),
        ),
      ],
    );
  }
}

class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({
    super.key,
    required this.aboutInfo,
  });

  final AppAboutInfo aboutInfo;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'ABOUT',
      children: [
        _AboutRow(label: 'Versi Aplikasi', value: aboutInfo.appVersion),
        _AboutRow(label: 'Versi Database', value: aboutInfo.databaseVersion),
        _AboutRow(label: 'Build Number', value: aboutInfo.buildNumber),
        _AboutRow(
          label: 'Developer',
          value: aboutInfo.developer,
          showDivider: false,
        ),
        const SizedBox(height: AppSpacing.s8),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: SettingsTheme.tileTitleStyle),
              ),
              Text(value, style: SettingsTheme.valueStyle),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}
