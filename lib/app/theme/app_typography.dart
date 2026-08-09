import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

/// Application typography tokens using Poppins.
abstract final class AppTypography {
  static TextTheme light(ColorScheme colorScheme) => _buildTextTheme(
        primary: AppColors.textPrimary,
        secondary: AppColors.textSecondary,
        onPrimary: colorScheme.onPrimary,
      );

  static TextTheme dark(ColorScheme colorScheme) => _buildTextTheme(
        primary: AppColors.textPrimaryDark,
        secondary: AppColors.textSecondaryDark,
        onPrimary: colorScheme.onPrimary,
      );

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color onPrimary,
  }) {
    final base = GoogleFonts.poppinsTextTheme();

    return base.copyWith(
      // Display
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 64 / 57,
        letterSpacing: -0.25,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 52 / 45,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 44 / 36,
        color: primary,
      ),

      // Headline
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: primary,
      ),

      // Title
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        letterSpacing: 0.15,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.1,
        color: primary,
      ),

      // Body
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.5,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0.25,
        color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        letterSpacing: 0.4,
        color: secondary,
      ),

      // Label
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.5,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        letterSpacing: 0.5,
        color: secondary,
      ),
    );
  }
}
