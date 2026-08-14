import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';

class MembershipCardTheme {
  const MembershipCardTheme({
    required this.gradientColors,
    required this.highlightColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.pointAccentColor,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.glossColor,
    required this.shadowColor,
  });

  final List<Color> gradientColors;
  final Color highlightColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color pointAccentColor;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color glossColor;
  final Color shadowColor;
}

extension MembershipLevelTheme on MembershipLevel {
  MembershipCardTheme get cardTheme => switch (this) {
        MembershipLevel.bronze => const MembershipCardTheme(
            gradientColors: [
              Color(0xFF5C3A1E),
              Color(0xFFB87333),
              Color(0xFF8B5A2B),
            ],
            highlightColor: Color(0xFFD4956A),
            borderColor: Color(0xFF6B4423),
            primaryTextColor: Color(0xFFFFF8F0),
            secondaryTextColor: Color(0xFFF5E6D8),
            pointAccentColor: AppColors.brandYellow,
            buttonBackground: AppColors.brandYellow,
            buttonForeground: AppColors.brandBlue,
            glossColor: Color(0xFFFFE4C4),
            shadowColor: Color(0xFF3D2512),
          ),
        MembershipLevel.silver => const MembershipCardTheme(
            gradientColors: [
              Color(0xFF7A8088),
              Color(0xFFC8CCD2),
              Color(0xFF9AA1A9),
            ],
            highlightColor: Color(0xFFE8EAED),
            borderColor: Color(0xFF8E959E),
            primaryTextColor: Color(0xFF1A1A2E),
            secondaryTextColor: Color(0xFF374151),
            pointAccentColor: AppColors.brandBlue,
            buttonBackground: AppColors.brandBlue,
            buttonForeground: Colors.white,
            glossColor: Color(0xFFFFFFFF),
            shadowColor: Color(0xFF4B5563),
          ),
        MembershipLevel.gold => const MembershipCardTheme(
            gradientColors: [
              Color(0xFF9A7B1A),
              Color(0xFFD4AF37),
              Color(0xFFB8962E),
            ],
            highlightColor: AppColors.brandYellow,
            borderColor: Color(0xFFC5A028),
            primaryTextColor: Color(0xFF3D2E00),
            secondaryTextColor: Color(0xFF5C4A00),
            pointAccentColor: Color(0xFF5C4A00),
            buttonBackground: AppColors.brandBlue,
            buttonForeground: Colors.white,
            glossColor: Color(0xFFFFF8DC),
            shadowColor: Color(0xFF6B5A10),
          ),
        MembershipLevel.platinum => const MembershipCardTheme(
            gradientColors: [
              Color(0xFF3D4452),
              Color(0xFFB8BCC8),
              Color(0xFF6E7684),
            ],
            highlightColor: Color(0xFFE2E6EE),
            borderColor: Color(0xFF9AA3B2),
            primaryTextColor: Colors.white,
            secondaryTextColor: Color(0xFFE5E7EB),
            pointAccentColor: AppColors.brandYellow,
            buttonBackground: AppColors.brandYellow,
            buttonForeground: AppColors.brandBlue,
            glossColor: Color(0xFFFFFFFF),
            shadowColor: Color(0xFF1F2937),
          ),
      };
}
