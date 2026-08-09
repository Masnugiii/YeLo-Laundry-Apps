import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_badge.dart';

class LoyaltyClassCard extends StatelessWidget {
  const LoyaltyClassCard({
    super.key,
    required this.loyaltyClass,
  });

  final LoyaltyClass loyaltyClass;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Class Benefits',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                LoyaltyBadge(loyaltyClass: loyaltyClass),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            for (var i = 0; i < loyaltyClass.benefits.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: AppSpacing.s8),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.s8),
              ],
              Text(
                loyaltyClass.benefits[i],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
