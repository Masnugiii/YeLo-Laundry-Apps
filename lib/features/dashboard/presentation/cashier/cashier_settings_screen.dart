import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/account_logout_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class CashierSettingsScreen extends ConsumerStatefulWidget {
  const CashierSettingsScreen({
    super.key,
    this.showBackButton = false,
    this.showBackToDashboard = false,
  });

  final bool showBackButton;
  final bool showBackToDashboard;

  @override
  ConsumerState<CashierSettingsScreen> createState() =>
      _CashierSettingsScreenState();
}

class _CashierSettingsScreenState extends ConsumerState<CashierSettingsScreen> {
  AppSettingsState _settings = initialAppSettings;

  void _updateSettings(AppSettingsState settings) {
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(staffPermissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading:
            widget.showBackButton && !widget.showBackToDashboard,
        leading: widget.showBackToDashboard
            ? const DashboardAppBarBackButton()
            : null,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          widget.showBackToDashboard ? 'Akun' : 'Settings',
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
          if (permissions.notification) ...[
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
              if (permissions.orderNumberSettingsReadOnly)
                SettingsNavigationTile(
                  title: 'Penomoran Order (Lihat Saja)',
                  onTap: () => context.push(
                    '/settings/order-number?readOnly=true',
                  ),
                ),
              if (permissions.receiptPrinterSettings)
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
              'Pengaturan lainnya tersedia untuk role dengan akses Settings.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          const AccountLogoutSection(),
        ],
      ),
    );
  }
}
