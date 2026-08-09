import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/cashier_permissions.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class CashierSettingsScreen extends StatefulWidget {
  const CashierSettingsScreen({
    super.key,
    this.showBackButton = false,
  });

  final bool showBackButton;

  @override
  State<CashierSettingsScreen> createState() => _CashierSettingsScreenState();
}

class _CashierSettingsScreenState extends State<CashierSettingsScreen> {
  AppSettingsState _settings = initialAppSettings;

  void _updateSettings(AppSettingsState settings) {
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          if (CashierPermissions.notificationCenter) ...[
            SettingsSectionCard(
              title: 'NOTIFICATION CENTER',
              children: [
                SettingsNavigationTile(
                  title: 'Lihat Semua Notifikasi',
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            NotificationSettingsSection(
              settings: _settings,
              onChanged: _updateSettings,
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
          SettingsSectionCard(
            title: 'ORDER & RECEIPT',
            children: [
              if (CashierPermissions.orderNumberSettingsReadOnly)
                SettingsNavigationTile(
                  title: 'Penomoran Order (Lihat Saja)',
                  onTap: () => context.push(
                    '/settings/order-number?readOnly=true',
                  ),
                ),
              if (CashierPermissions.receiptPrinterSettings)
                SettingsNavigationTile(
                  title: 'Pengaturan Struk (Printer & Kertas)',
                  onTap: () => context.push('/settings/cashier/receipt-printer'),
                  showDivider: false,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              'Akses terbatas untuk peran Kasir. Laporan keuangan, pengeluaran, '
              'KPI karyawan, profil laundry, dan pengaturan sistem hanya dapat '
              'diakses oleh Owner.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
