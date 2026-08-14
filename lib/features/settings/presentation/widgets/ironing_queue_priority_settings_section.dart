import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/models/ironing_queue_priority_settings.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/ironing_queue_priority_provider.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class IroningQueuePrioritySettingsSection extends ConsumerWidget {
  const IroningQueuePrioritySettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(ironingQueuePriorityProvider);
    final notifier = ref.read(ironingQueuePriorityProvider.notifier);

    return SettingsSectionCard(
      title: 'IRONING QUEUE PRIORITY',
      children: [
        SettingsCheckboxTile(
          title: 'Binatu First',
          value: settings.binatuFirst,
          onChanged: (value) => notifier.setBinatuFirst(value ?? true),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s8,
            AppSpacing.s20,
            AppSpacing.s4,
          ),
          child: Text(
            'Waiting Time',
            style: SettingsTheme.tileTitleStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            0,
            AppSpacing.s20,
            AppSpacing.s12,
          ),
          child: DropdownButtonFormField<int>(
            initialValue: settings.waitingTimeMinutes,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.dashboardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
            ),
            items: [
              for (final minutes in ironingQueueWaitingTimeOptions)
                DropdownMenuItem(
                  value: minutes,
                  child: Text(
                    '$minutes Minutes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                notifier.setWaitingTimeMinutes(value);
              }
            },
          ),
        ),
        SettingsCheckboxTile(
          title: 'Allow Operator Assistance',
          value: settings.allowOperatorAssistance,
          showDivider: false,
          onChanged: (value) =>
              notifier.setAllowOperatorAssistance(value ?? true),
        ),
      ],
    );
  }
}
