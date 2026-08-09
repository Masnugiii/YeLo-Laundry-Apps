import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';

class LoyaltyProgressWidget extends StatelessWidget {
  const LoyaltyProgressWidget({
    super.key,
    required this.progress,
    this.labelColor,
    this.trackColor,
    this.fillColor,
    this.useIndonesianLabels = false,
    this.useIndonesianPercentFirst = false,
  });

  final LoyaltyProgress progress;
  final Color? labelColor;
  final Color? trackColor;
  final Color? fillColor;
  final bool useIndonesianLabels;
  final bool useIndonesianPercentFirst;

  @override
  Widget build(BuildContext context) {
    final titleColor = labelColor ?? AppColors.textPrimary;
    final barTrackColor =
        trackColor ?? AppColors.onPrimary.withValues(alpha: 0.2);
    final barFillColor = fillColor ?? AppColors.accent;

    final progressLabel = progress.isMaxLevel
        ? 'Level Tertinggi'
        : useIndonesianPercentFirst
            ? '${progress.percent}% menuju ${progress.nextClass!.label}'
            : useIndonesianLabels
                ? 'Menuju ${progress.nextClass!.label}'
                : 'Progress to ${progress.nextClass!.label}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          progressLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: titleColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.progress,
            minHeight: 10,
            backgroundColor: barTrackColor,
            color: barFillColor,
          ),
        ),
        if (!useIndonesianPercentFirst && !progress.isMaxLevel) ...[
          const SizedBox(height: AppSpacing.s4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${progress.percent}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
