import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/data/dummy_unpaid_orders.dart';
import 'package:yelo_laundry_erp/features/orders/models/unpaid_order.dart';

class UnpaidOrdersSummaryGrid extends StatelessWidget {
  const UnpaidOrdersSummaryGrid({
    super.key,
    required this.summary,
  });

  final UnpaidOrdersSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s12,
      runSpacing: AppSpacing.s12,
      children: [
        _SummaryCard(
          label: 'Total Order Belum Dibayar',
          value: '${summary.totalOrders}',
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.primary,
        ),
        _SummaryCard(
          label: 'Total Nilai Piutang',
          value: formatUnpaidAmount(summary.totalReceivable),
          icon: Icons.payments_outlined,
          iconColor: AppColors.primary,
        ),
        _SummaryCard(
          label: 'Jatuh Tempo Hari Ini',
          value: '${summary.dueTodayCount}',
          icon: Icons.event_outlined,
          iconColor: AppColors.warning,
        ),
        _SummaryCard(
          label: 'Terlambat Diambil',
          value: '${summary.latePickupCount}',
          icon: Icons.schedule_outlined,
          iconColor: AppColors.error,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width -
            AppSpacing.s20 * 2 -
            AppSpacing.s12) /
        2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
