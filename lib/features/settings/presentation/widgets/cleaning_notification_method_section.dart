import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class CleaningNotificationMethodSection extends StatelessWidget {
  const CleaningNotificationMethodSection({
    super.key,
    required this.whatsappEnabled,
    required this.inAppEnabled,
    required this.onWhatsappChanged,
    required this.onInAppChanged,
  });

  final bool whatsappEnabled;
  final bool inAppEnabled;
  final ValueChanged<bool> onWhatsappChanged;
  final ValueChanged<bool> onInAppChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Method',
          style: SettingsTheme.tileTitleStyle,
        ),
        const SizedBox(height: 4),
        SettingsSwitchTile(
          title: 'WhatsApp Reminder',
          description:
              'Kirim pengingat operasional melalui WhatsApp kepada penerima yang dipilih.',
          value: whatsappEnabled,
          onChanged: onWhatsappChanged,
        ),
        SettingsSwitchTile(
          title: 'In-App Notification',
          description:
              'Tampilkan notifikasi pengingat secara langsung di aplikasi Yelo Laundry.',
          value: inAppEnabled,
          showDivider: false,
          onChanged: onInAppChanged,
        ),
      ],
    );
  }
}
