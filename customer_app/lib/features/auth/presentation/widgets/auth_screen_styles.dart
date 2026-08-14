import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';

abstract final class AuthScreenStyles {
  static const logoAsset = 'assets/images/Logo_WithBackground_Customer.png';
  static const peopleHighlightColor = AppColors.brandYellow;
  static const primaryButtonHeight = 52.0;
  static const inputFontSize = 16.0;

  static TextStyle poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: poppins(
        fontSize: inputFontSize,
        color: AppColors.textSecondary,
      ),
      hintText: hintText,
      hintStyle: poppins(
        fontSize: inputFontSize,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s16,
      ),
      constraints: const BoxConstraints(minHeight: 52),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.brandBlue,
      disabledBackgroundColor: AppColors.brandBlue.withValues(alpha: 0.6),
      minimumSize: const Size.fromHeight(primaryButtonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
