import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_badge.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_progress_widget.dart';
import 'package:yelo_laundry_erp/features/points/utils/points_formatter.dart';

class LoyaltySummaryCard extends StatelessWidget {
  const LoyaltySummaryCard({
    super.key,
    required this.customerName,
    required this.currentPoints,
    required this.loyaltyProgress,
  });

  final String customerName;
  final int currentPoints;
  final LoyaltyProgress loyaltyProgress;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                LoyaltyBadge(loyaltyClass: loyaltyProgress.currentClass),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              'Current Point',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              formatPoints(currentPoints),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Container(
              height: 1,
              color: AppColors.onPrimary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Current Class',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              loyaltyProgress.currentClass.label,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            LoyaltyProgressWidget(
              progress: loyaltyProgress,
              labelColor: AppColors.onPrimary,
              trackColor: AppColors.onPrimary.withValues(alpha: 0.2),
              fillColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
