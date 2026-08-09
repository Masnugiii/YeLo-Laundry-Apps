import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class SystemConfigSettingsSection extends StatelessWidget {
  const SystemConfigSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'KONFIGURASI SISTEM',
      children: [
        SettingsNavigationTile(
          title: 'Profil Perusahaan',
          onTap: () => context.push('/settings/company'),
        ),
        SettingsNavigationTile(
          title: 'Absensi',
          onTap: () => context.push('/settings/attendance-config'),
        ),
        SettingsNavigationTile(
          title: 'Aturan Dokumen',
          onTap: () => context.push('/settings/documents-config'),
        ),
        SettingsNavigationTile(
          title: 'Notifikasi',
          onTap: () => context.push('/settings/notifications-config'),
        ),
        SettingsNavigationTile(
          title: 'Backup',
          onTap: () => context.push('/settings/backup-config'),
        ),
        SettingsNavigationTile(
          title: 'Delivery',
          showDivider: false,
          onTap: () => context.push('/settings/delivery-config'),
        ),
      ],
    );
  }
}
