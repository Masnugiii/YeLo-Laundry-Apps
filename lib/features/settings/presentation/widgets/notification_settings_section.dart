import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class NotificationSettingsSection extends StatelessWidget {
  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'NOTIFICATION',
      children: [
        SettingsNavigationTile(
          title: 'Notification Center',
          onTap: () => context.push('/notifications'),
        ),
        SettingsSwitchTile(
          title: 'Suara saat Order Baru Masuk',
          description: 'Putar suara ketika terdapat order laundry baru.',
          value: settings.soundOnNewOrder,
          onChanged: (value) =>
              onChanged(settings.copyWith(soundOnNewOrder: value)),
        ),
        SettingsSwitchTile(
          title: 'Getar Saat Order Baru',
          value: settings.vibrateOnNewOrder,
          onChanged: (value) =>
              onChanged(settings.copyWith(vibrateOnNewOrder: value)),
        ),
        SettingsSwitchTile(
          title: 'Tampilkan Popup Order Baru',
          value: settings.showNewOrderPopup,
          showDivider: false,
          onChanged: (value) =>
              onChanged(settings.copyWith(showNewOrderPopup: value)),
        ),
      ],
    );
  }
}
