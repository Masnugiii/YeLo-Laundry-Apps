import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: SettingsTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                AppSpacing.s8,
              ),
              child: Text(title, style: SettingsTheme.sectionTitleStyle),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.showDivider = true,
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchTheme(
          data: SettingsTheme.switchTheme,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
            ),
            title: Text(title, style: SettingsTheme.tileTitleStyle),
            subtitle: description == null
                ? null
                : Text(description!, style: SettingsTheme.tileDescriptionStyle),
            value: value,
            onChanged: onChanged,
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

class SettingsNavigationTile extends StatelessWidget {
  const SettingsNavigationTile({
    super.key,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
          ),
          title: Text(title, style: SettingsTheme.tileTitleStyle),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
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

class SettingsCheckboxTile extends StatelessWidget {
  const SettingsCheckboxTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
          ),
          title: Text(title, style: SettingsTheme.tileTitleStyle),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          checkColor: AppColors.onPrimary,
          controlAffinity: ListTileControlAffinity.leading,
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
