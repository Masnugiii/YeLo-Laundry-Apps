import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_badge.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_progress_widget.dart';
import 'package:yelo_laundry_erp/features/points/utils/points_formatter.dart';

class PointRewardsCard extends StatelessWidget {
  const PointRewardsCard({
    super.key,
    required this.points,
    required this.onHistoryPressed,
  });

  final int points;
  final VoidCallback onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final loyaltyClass = loyaltyClassFromPoints(points);
    final loyaltyProgress = loyaltyProgressFromPoints(points);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Point Rewards',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              LoyaltyBadge(loyaltyClass: loyaltyClass),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Current Point',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            '${formatPoints(points)} Point',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (!loyaltyProgress.isMaxLevel) ...[
            const SizedBox(height: AppSpacing.s16),
            LoyaltyProgressWidget(
              progress: loyaltyProgress,
              useIndonesianPercentFirst: true,
              trackColor: AppColors.divider,
              fillColor: AppColors.primary,
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onHistoryPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Riwayat Point',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
