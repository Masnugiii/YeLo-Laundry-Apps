import 'package:flutter/material.dart';

/// Application color tokens.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF033B8E);
  static const Color accent = Color(0xFFF8D613);

  // Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color dashboardBackground = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Borders
  static const Color divider = Color(0xFFE5E7EB);

  // On-colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFF033B8E);

  // Dark theme
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceDarkElevated = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF42A5F5);
  static const Color accentDark = Color(0xFFF8D613);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF374151);
  static const Color onPrimaryDark = Color(0xFF0F172A);
}
