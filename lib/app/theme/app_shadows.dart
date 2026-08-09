import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

/// Reusable shadow tokens.
abstract final class AppShadows {
  static List<BoxShadow> sm({Color? color}) => [
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> md({Color? color}) => [
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.04),
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> lg({Color? color}) => [
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> xl({Color? color}) => [
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> forBrightness(Brightness brightness, AppShadowSize size) {
    final color = brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return switch (size) {
      AppShadowSize.sm => sm(color: color),
      AppShadowSize.md => md(color: color),
      AppShadowSize.lg => lg(color: color),
      AppShadowSize.xl => xl(color: color),
    };
  }
}

enum AppShadowSize { sm, md, lg, xl }
