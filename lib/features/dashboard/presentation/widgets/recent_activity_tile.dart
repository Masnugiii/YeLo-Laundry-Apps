import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.status,
    this.statusColor = AppColors.primary,
    this.useOwnerStyle = false,
  });

  final String orderId;
  final String customerName;
  final String status;
  final Color statusColor;
  final bool useOwnerStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: EdgeInsets.all(useOwnerStyle ? AppSpacing.s20 : AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: useOwnerStyle ? null : Border.all(color: AppColors.divider),
        boxShadow: useOwnerStyle ? AppShadows.md() : null,
      ),
      child: Row(
        children: [
          Container(
            width: useOwnerStyle ? 48 : 44,
            height: useOwnerStyle ? 48 : 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: useOwnerStyle ? 26 : 24,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: GoogleFonts.poppins(
                    fontSize: useOwnerStyle ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  customerName,
                  style: GoogleFonts.poppins(
                    fontSize: useOwnerStyle ? 14 : 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: useOwnerStyle ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
