import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/cleaning_notification_method_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/maintenance_read_only_schedule.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/upcoming_maintenance_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/whatsapp_recipient_section.dart';

class MaintenanceSection extends StatelessWidget {
  const MaintenanceSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  bool get _hasActiveReminder =>
      settings.machineServiceReminderEnabled ||
      settings.routineCleaningReminderEnabled;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'MAINTENANCE',
      children: [
        SettingsSwitchTile(
          title: 'Aktifkan Pengingat Service Mesin',
          description:
              'Kirim pengingat jadwal service mesin cuci dan dryer setiap 2 bulan sesuai SOP Yelo Laundry.',
          value: settings.machineServiceReminderEnabled,
          onChanged: (value) => onChanged(
            settings.copyWith(machineServiceReminderEnabled: value),
          ),
        ),
        if (settings.machineServiceReminderEnabled)
          const MaintenanceReadOnlySchedule(),
        SettingsSwitchTile(
          title: 'Routine Cleaning Reminder',
          description:
              'Kirim pengingat pembersihan menyeluruh area operasional laundry setiap 2 bulan sesuai SOP Yelo Laundry.',
          value: settings.routineCleaningReminderEnabled,
          showDivider: !_hasActiveReminder,
          onChanged: (value) => onChanged(
            settings.copyWith(routineCleaningReminderEnabled: value),
          ),
        ),
        if (settings.routineCleaningReminderEnabled)
          const MaintenanceReadOnlySchedule(),
        if (_hasActiveReminder) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              0,
            ),
            child: CleaningNotificationMethodSection(
              whatsappEnabled: settings.cleaningWhatsappNotification,
              inAppEnabled: settings.cleaningInAppNotification,
              onWhatsappChanged: (value) => onChanged(
                settings.copyWith(cleaningWhatsappNotification: value),
              ),
              onInAppChanged: (value) => onChanged(
                settings.copyWith(cleaningInAppNotification: value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              0,
            ),
            child: WhatsappRecipientSection(
              settings: settings,
              onChanged: onChanged,
              sectionTitle: 'Send Reminder To',
            ),
          ),
          const UpcomingMaintenanceCard(schedule: upcomingMaintenanceSchedule),
        ],
      ],
    );
  }
}

// Keep backward-compatible export name used by settings_screen.
typedef ServiceReminderSection = MaintenanceSection;
