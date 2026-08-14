import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/membership/customer_membership_provider.dart';
import 'package:yelo_laundry_customer/core/membership/membership_card_shell.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/membership/membership_theme.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  String _avatarInitial(CustomerSession session) {
    final name = session.fullName.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'Y';
  }

  String _customerDisplayName(CustomerSession session) {
    final name = session.fullName.trim();
    if (name.isEmpty) return 'Customer';
    return name.split(RegExp(r'\s+')).first;
  }

  String _membershipTitle(MembershipLevel level) {
    final label = level.label;
    final title =
        '${label[0]}${label.substring(1).toLowerCase()}';
    return '$title Member';
  }

  Widget _buildAvatar(CustomerSession session) {
    const avatarRadius = 26.0;
    const profileCircleColor = Color(0xFFF4E900);
    final photoUrl = session.photoUrl?.trim();
    final initial = _avatarInitial(session);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: avatarRadius,
        backgroundColor: profileCircleColor,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: profileCircleColor,
      child: Text(
        initial,
        style: _poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }

  String _formatPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.startsWith('+62')) {
      final digits = trimmed.substring(3);
      if (digits.length >= 9) {
        return '+62 ${digits.substring(0, digits.length - 8)} ${digits.substring(digits.length - 8)}';
      }
    }

    return trimmed;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_ProfileMenuEntry> items,
    required void Function(String route) onNavigate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        PickupDashboardCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _ProfileMenuTile(
                  item: items[i],
                  onTap: items[i].onTap == null
                      ? null
                      : () {
                          final action = items[i].onTap;
                          if (action != null) action(onNavigate);
                        },
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                    indent: 64,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildProfileMenuSections(
    BuildContext context,
    CustomerSession session,
  ) {
    final email = session.email?.trim();
    final hasEmail = email != null && email.isNotEmpty;

    final dataDiriItems = <_ProfileMenuEntry>[
      _ProfileMenuEntry(
        icon: Icons.badge_outlined,
        label: 'Nama',
        value: session.fullName.trim().isEmpty ? '-' : session.fullName.trim(),
        onTap: (navigate) => navigate('/profile/edit'),
      ),
      _ProfileMenuEntry(
        icon: Icons.phone_outlined,
        label: 'Nomor WhatsApp',
        value: session.phone.trim().isEmpty
            ? '-'
            : _formatPhone(session.phone),
      ),
      if (hasEmail)
        _ProfileMenuEntry(
          icon: Icons.email_outlined,
          label: 'Email',
          value: email,
          onTap: (navigate) => navigate('/profile/edit'),
        ),
    ];

    final akunItems = <_ProfileMenuEntry>[
      _ProfileMenuEntry(
        icon: Icons.location_on_outlined,
        label: 'Alamat',
        onTap: (navigate) => navigate('/addresses'),
      ),
      _ProfileMenuEntry(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Yelo Wallet',
        onTap: (navigate) => navigate('/wallet'),
      ),
      _ProfileMenuEntry(
        icon: Icons.stars_outlined,
        label: 'Yelo Point',
        onTap: (navigate) => navigate('/rewards'),
      ),
      _ProfileMenuEntry(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        onTap: (navigate) => navigate('/notifications'),
      ),
      _ProfileMenuEntry(
        icon: Icons.settings_outlined,
        label: 'Pengaturan',
        onTap: (navigate) => navigate('/settings'),
      ),
    ];

    final bantuanItems = <_ProfileMenuEntry>[
      _ProfileMenuEntry(
        icon: Icons.help_outline,
        label: 'Pusat Bantuan',
        onTap: (navigate) => navigate('/help'),
      ),
      _ProfileMenuEntry(
        icon: Icons.privacy_tip_outlined,
        label: 'Kebijakan Privasi',
        onTap: (navigate) => navigate('/privacy-policy'),
      ),
      _ProfileMenuEntry(
        icon: Icons.description_outlined,
        label: 'Syarat & Ketentuan',
        onTap: (navigate) => navigate('/terms-and-conditions'),
      ),
    ];

    final tentangItems = <_ProfileMenuEntry>[
      _ProfileMenuEntry(
        icon: Icons.info_outline,
        label: 'Tentang Yelo',
        onTap: (navigate) => navigate('/about'),
      ),
    ];

    void navigate(String route) => context.push(route);

    return [
      _buildMenuSection(
        title: 'Data Diri',
        items: dataDiriItems,
        onNavigate: navigate,
      ),
      const SizedBox(height: AppSpacing.s16),
      _buildMenuSection(
        title: 'Akun & Keamanan',
        items: akunItems,
        onNavigate: navigate,
      ),
      const SizedBox(height: AppSpacing.s16),
      _buildMenuSection(
        title: 'Bantuan',
        items: bantuanItems,
        onNavigate: navigate,
      ),
      const SizedBox(height: AppSpacing.s16),
      _buildMenuSection(
        title: 'Tentang',
        items: tentangItems,
        onNavigate: navigate,
      ),
      const SizedBox(height: AppSpacing.s16),
      const _ProfileAppVersionTile(),
    ];
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s8,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Akun',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    CustomerSession session,
    MembershipLevel membershipLevel,
  ) {
    final theme = membershipLevel.cardTheme;
    final displayName = _customerDisplayName(session);

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          InkWell(
            onTap: () => context.push('/profile/edit'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(session),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $displayName',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lihat profil',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(MembershipCardStyles.borderRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.gradientColors,
                ),
                border: Border.all(
                  color: theme.borderColor.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _membershipTitle(membershipLevel),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MembershipCardStyles.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            'Benefit membership kamu',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MembershipCardStyles.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Icon(
                      membershipLevel.icon,
                      size: 40,
                      color: theme.highlightColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: _ProfileMenuTile(
        item: const _ProfileMenuEntry(
          icon: Icons.logout,
          label: 'Keluar',
          isDestructive: true,
        ),
        onTap: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final membershipLevel = ref.watch(customerMembershipLevelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildDashboardHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                _buildProfileHeaderCard(context, session, membershipLevel),
                const SizedBox(height: AppSpacing.s16),
                ..._buildProfileMenuSections(context, session),
                const SizedBox(height: AppSpacing.s16),
                _buildLogoutButton(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuEntry {
  const _ProfileMenuEntry({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final void Function(void Function(String route) navigate)? onTap;
  final bool isDestructive;
}

class _ProfileAppVersionTile extends StatelessWidget {
  const _ProfileAppVersionTile();

  @override
  Widget build(BuildContext context) {
    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '—';

          return _ProfileMenuTile(
            item: _ProfileMenuEntry(
              icon: Icons.smartphone_outlined,
              label: 'Versi Aplikasi',
              value: version,
            ),
            onTap: null,
          );
        },
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.item,
    required this.onTap,
  });

  final _ProfileMenuEntry item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        item.isDestructive ? Colors.red.shade700 : AppColors.textPrimary;
    final iconColor =
        item.isDestructive ? Colors.red.shade700 : AppColors.brandBlue;
    final hasValue = item.value != null && item.value!.isNotEmpty;
    final showChevron = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          crossAxisAlignment:
              hasValue ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? Colors.red.shade50
                    : AppColors.brandBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  if (hasValue) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.value!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: item.isDestructive
                    ? Colors.red.shade300
                    : AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
