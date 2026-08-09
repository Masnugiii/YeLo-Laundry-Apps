import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

/// Shared visual tokens for the Pengeluaran module.
abstract final class ExpenseTheme {
  static const labelColor = Color(0xFF6B7280);
  static const categoryColor = Color(0xFF1F2937);
  static const metaColor = Color(0xFF6B7280);

  static const fieldRadius = BorderRadius.all(Radius.circular(16));

  static TextStyle labelStyle({double fontSize = 14}) => GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: labelColor,
      );

  static TextStyle valueStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = categoryColor,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static InputDecoration outlinedDecoration({
    String? hintText,
    TextStyle? hintStyle,
    BorderSide? borderSide,
    BorderSide? focusedBorderSide,
  }) {
    final border = borderSide ?? const BorderSide(color: AppColors.primary);
    final focusedBorder =
        focusedBorderSide ?? const BorderSide(color: AppColors.primary, width: 2);

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ??
          GoogleFonts.poppins(
            fontSize: 14,
            color: labelColor,
            height: 1.4,
          ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: border,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: focusedBorder,
      ),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: border,
      ),
    );
  }

  static InputDecorationTheme dropdownDecorationTheme({
    BorderSide? borderSide,
    BorderSide? focusedBorderSide,
  }) {
    final border = borderSide ?? const BorderSide(color: AppColors.primary);
    final focusedBorder =
        focusedBorderSide ?? const BorderSide(color: AppColors.primary, width: 2);

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: labelStyle(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: border,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: focusedBorder,
      ),
    );
  }
}
