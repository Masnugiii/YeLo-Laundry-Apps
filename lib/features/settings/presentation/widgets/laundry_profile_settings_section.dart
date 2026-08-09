import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class LaundryProfileSettingsSection extends StatelessWidget {
  const LaundryProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'LAUNDRY',
      children: [
        SettingsNavigationTile(
          title: 'Profil Laundry',
          showDivider: false,
          onTap: () => context.push('/settings/company'),
        ),
      ],
    );
  }
}
