import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class WhatsappReminderSection extends StatelessWidget {
  const WhatsappReminderSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'WHATSAPP REMINDER',
      children: [
        SettingsSwitchTile(
          title: 'Kirim Reminder ke WhatsApp',
          value: settings.whatsappReminderEnabled,
          showDivider: true,
          onChanged: (value) =>
              onChanged(settings.copyWith(whatsappReminderEnabled: value)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s4,
            AppSpacing.s20,
            AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contoh Pengingat',
                style: SettingsTheme.tileDescriptionStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  for (final example in whatsappReminderExamples)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dashboardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        example,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
