import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class WhatsappRecipientSection extends StatelessWidget {
  const WhatsappRecipientSection({
    super.key,
    required this.settings,
    required this.onChanged,
    this.sectionTitle,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle ?? 'Kirim Notifikasi Kepada',
          style: SettingsTheme.tileTitleStyle,
        ),
        const SizedBox(height: AppSpacing.s8),
        for (var i = 0; i < routineCleaningWhatsappRecipients.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s8),
          _RecipientRow(
            recipient: routineCleaningWhatsappRecipients[i],
            selected: _isSelected(routineCleaningWhatsappRecipients[i].role),
            onChanged: (value) => _updateRecipient(
              routineCleaningWhatsappRecipients[i].role,
              value ?? false,
            ),
            showDivider: i < routineCleaningWhatsappRecipients.length - 1,
          ),
        ],
      ],
    );
  }

  bool _isSelected(String role) => switch (role) {
        'Owner' => settings.cleaningNotifyOwner,
        'Manager' => settings.cleaningNotifyManager,
        _ => false,
      };

  void _updateRecipient(String role, bool value) {
    onChanged(
      switch (role) {
        'Owner' => settings.copyWith(cleaningNotifyOwner: value),
        'Manager' => settings.copyWith(cleaningNotifyManager: value),
        _ => settings,
      },
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({
    required this.recipient,
    required this.selected,
    required this.onChanged,
    required this.showDivider,
  });

  final WhatsappRecipientInfo recipient;
  final bool selected;
  final ValueChanged<bool?> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(recipient.role, style: SettingsTheme.tileTitleStyle),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: Text(
              recipient.phone,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          value: selected,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          checkColor: AppColors.onPrimary,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
