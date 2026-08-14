import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_menu_section.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/auth_screen_styles.dart';
import 'package:yelo_laundry_customer/features/help/data/about_content.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfoFuture = PackageInfo.fromPlatform();

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        style: _poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final logoWidth = (MediaQuery.sizeOf(context).width * 0.42).clamp(120.0, 180.0);

    return Center(
      child: Image.asset(
        AuthScreenStyles.logoAsset,
        width: logoWidth,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: _poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: _poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(PackageInfo? packageInfo) {
    final version = packageInfo?.version;
    final buildNumber = packageInfo?.buildNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informasi Aplikasi'),
        PickupDashboardCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (version != null && version.isNotEmpty)
                _buildInfoRow(label: 'Versi Aplikasi', value: version),
              if (version != null &&
                  version.isNotEmpty &&
                  buildNumber != null &&
                  buildNumber.isNotEmpty)
                const Divider(height: 1, color: AppColors.divider),
              if (buildNumber != null && buildNumber.isNotEmpty)
                _buildInfoRow(label: 'Build', value: buildNumber),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalMenu(BuildContext context) {
    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          DashboardMenuTile(
            entry: DashboardMenuEntry(
              icon: Icons.privacy_tip_outlined,
              label: 'Kebijakan Privasi',
              onTap: () => context.push('/privacy-policy'),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 64),
          DashboardMenuTile(
            entry: DashboardMenuEntry(
              icon: Icons.description_outlined,
              label: 'Syarat & Ketentuan',
              onTap: () => context.push('/terms-and-conditions'),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider, indent: 64),
          DashboardMenuTile(
            entry: DashboardMenuEntry(
              icon: Icons.help_outline,
              label: 'Pusat Bantuan',
              onTap: () => context.push('/help'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    final year = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Center(
        child: Text(
          '© $year Yelo',
          textAlign: TextAlign.center,
          style: _poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Tentang'),
          Expanded(
            child: FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s16,
                    AppSpacing.s16,
                    AppSpacing.s24,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.s8),
                    _buildLogo(context),
                    const SizedBox(height: AppSpacing.s24),
                    _buildSectionTitle('Tentang Yelo'),
                    Text(
                      AboutContent.description,
                      style: _poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildAppInfoCard(snapshot.data),
                    const SizedBox(height: AppSpacing.s16),
                    _buildLegalMenu(context),
                    const SizedBox(height: AppSpacing.s20),
                    _buildCopyright(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
