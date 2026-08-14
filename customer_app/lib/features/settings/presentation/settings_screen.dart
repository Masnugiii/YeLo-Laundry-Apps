import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_menu_section.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Pengaturan'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                DashboardMenuSection(
                  title: 'Preferensi',
                  items: [
                    const DashboardMenuEntry(
                      icon: Icons.language,
                      label: 'Bahasa',
                      value: 'Indonesia',
                      onTap: null,
                    ),
                    const DashboardMenuEntry(
                      icon: Icons.brightness_6_outlined,
                      label: 'Tema',
                      value: 'Sistem',
                      onTap: null,
                    ),
                    DashboardMenuEntry(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi Aplikasi',
                      trailing: Switch.adaptive(
                        value: _pushNotificationsEnabled,
                        activeThumbColor: AppColors.brandBlue,
                        activeTrackColor:
                            AppColors.brandBlue.withValues(alpha: 0.35),
                        onChanged: (value) {
                          setState(() => _pushNotificationsEnabled = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                DashboardMenuSection(
                  title: 'Keamanan',
                  items: [
                    DashboardMenuEntry(
                      icon: Icons.phone_android_outlined,
                      label: 'Ganti Nomor HP',
                      onTap: () => context.push('/settings/change-phone'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                DashboardMenuSection(
                  title: 'Bantuan',
                  items: [
                    DashboardMenuEntry(
                      icon: Icons.help_outline,
                      label: 'Pusat Bantuan',
                      onTap: () => context.push('/help'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                DashboardMenuSection(
                  title: 'Legal',
                  items: [
                    DashboardMenuEntry(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Kebijakan Privasi',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                    DashboardMenuEntry(
                      icon: Icons.description_outlined,
                      label: 'Syarat & Ketentuan',
                      onTap: () => context.push('/terms-and-conditions'),
                    ),
                    DashboardMenuEntry(
                      icon: Icons.info_outline,
                      label: 'Tentang',
                      onTap: () => context.push('/about'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                PickupDashboardCard(
                  padding: EdgeInsets.zero,
                  child: DashboardMenuTile(
                    entry: DashboardMenuEntry(
                      icon: Icons.logout,
                      label: 'Keluar',
                      isDestructive: true,
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
