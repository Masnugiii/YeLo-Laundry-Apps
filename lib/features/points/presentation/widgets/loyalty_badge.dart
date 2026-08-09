import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';

class LoyaltyBadge extends StatelessWidget {
  const LoyaltyBadge({
    super.key,
    required this.loyaltyClass,
  });

  final LoyaltyClass loyaltyClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: loyaltyClass.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        loyaltyClass.label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: loyaltyClass.badgeText,
        ),
      ),
    );
  }
}
