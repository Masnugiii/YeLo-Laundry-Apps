import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor,
    this.useOwnerStyle = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final bool useOwnerStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(useOwnerStyle ? AppSpacing.s20 : AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: useOwnerStyle ? null : Border.all(color: AppColors.divider),
        boxShadow: useOwnerStyle ? AppShadows.md() : AppShadows.sm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: useOwnerStyle ? 48 : 40,
            height: useOwnerStyle ? 48 : 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: useOwnerStyle ? 26 : 22,
            ),
          ),
          SizedBox(height: useOwnerStyle ? AppSpacing.s16 : AppSpacing.s12),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: useOwnerStyle ? 22 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: useOwnerStyle ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
