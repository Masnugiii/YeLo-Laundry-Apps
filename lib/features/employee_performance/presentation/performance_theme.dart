import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/employee_performance/models/employee_performance_models.dart';

abstract final class PerformanceTheme {
  static const cardRadius = BorderRadius.all(Radius.circular(20));
  static const successBackground = Color(0xFFE8F5E9);
  static const successBorder = Color(0xFF4CAF50);

  static TextStyle sectionTitleStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitleStyle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle labelStyle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle valueStyle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: cardRadius,
    boxShadow: AppShadows.md(),
  );

  static Color levelColor(PerformanceLevel level) => switch (level) {
        PerformanceLevel.excellent => AppColors.success,
        PerformanceLevel.good => AppColors.primary,
        PerformanceLevel.needImprovement => AppColors.warning,
      };

  static Widget sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: sectionTitleStyle),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(subtitle, style: subtitleStyle),
          ],
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }
}
