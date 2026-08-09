import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_notification_badge.dart';

class PosMenuCard extends StatelessWidget {
  const PosMenuCard({
    super.key,
    required this.title,
    this.icon,
    this.emoji,
    this.onTap,
    this.highlight = false,
    this.badgeCount = 0,
  }) : assert(icon != null || emoji != null, 'icon or emoji is required');

  final String title;
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onTap;
  final bool highlight;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconColor = highlight ? AppColors.accent : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.md(),
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardRadius,
            child: SizedBox(
              height: 78,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                child: Row(
                  children: [
                    _MenuIcon(
                      icon: icon,
                      emoji: emoji,
                      iconColor: iconColor,
                      highlight: highlight,
                      badgeCount: badgeCount,
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({
    required this.icon,
    required this.emoji,
    required this.iconColor,
    required this.highlight,
    required this.badgeCount,
  });

  final IconData? icon;
  final String? emoji;
  final Color iconColor;
  final bool highlight;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconContainer = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accent.withValues(alpha: 0.18)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
      ),
      child: emoji != null
          ? Center(
              child: Text(
                emoji!,
                style: const TextStyle(fontSize: 24),
              ),
            )
          : Icon(icon, color: iconColor, size: 28),
    );

    if (badgeCount <= 0) {
      return iconContainer;
    }

    return ErpNotificationBadge(
      count: badgeCount,
      child: iconContainer,
    );
  }
}
