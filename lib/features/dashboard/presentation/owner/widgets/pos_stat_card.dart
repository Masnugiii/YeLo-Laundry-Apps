import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class PosStatCard extends StatelessWidget {
  const PosStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.emoji,
    this.highlight = false,
    this.onTap,
  }) : assert(icon != null || emoji != null, 'Provide icon or emoji');

  final String title;
  final String value;
  final IconData? icon;
  final String? emoji;
  final bool highlight;
  final VoidCallback? onTap;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final leadingColor = highlight ? AppColors.accent : AppColors.primary;

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 24, height: 1))
                : Icon(icon, color: leadingColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s4),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: _cardRadius,
        child: card,
      ),
    );
  }
}
