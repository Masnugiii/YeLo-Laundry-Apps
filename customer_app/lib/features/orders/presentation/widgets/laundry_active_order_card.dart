import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_progress_timeline.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

String laundryPhaseStatusLabel(int index, {bool compact = false}) {
  if (compact) {
    return switch (index) {
      0 => 'Diterima',
      1 => 'Diproses',
      2 => 'Dicuci',
      3 => 'Disetrika',
      4 => 'Siap Diambil',
      5 => 'Selesai',
      _ => 'Dalam Proses',
    };
  }

  return switch (index) {
    0 => 'Diterima',
    1 => 'Sedang Diproses',
    2 => 'Sedang Dicuci',
    3 => 'Sedang Disetrika',
    4 => 'Siap Diambil',
    5 => 'Selesai',
    _ => 'Dalam Proses',
  };
}

String laundryPhaseDescription(int index) {
  return switch (index) {
    0 => 'Pesanan kamu telah diterima.',
    1 => 'Pesanan kamu sedang diproses.',
    2 => 'Pesanan kamu sedang dicuci.',
    3 => 'Pesanan kamu sedang disetrika.',
    4 => 'Pesanan kamu siap diambil.',
    5 => 'Pesanan kamu telah selesai.',
    _ => 'Pesanan kamu sedang diproses.',
  };
}

/// Reusable active-order card for dashboard and laundry status screens.
class LaundryActiveOrderCard extends StatelessWidget {
  const LaundryActiveOrderCard({
    super.key,
    required this.order,
    required this.steps,
    this.onTap,
    this.compact = false,
  });

  final OrderItem order;
  final List<LaundryTrackingStep> steps;
  final VoidCallback? onTap;
  final bool compact;

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = resolveLaundryTimelineUiState(steps);
    final phaseLabel = laundryPhaseStatusLabel(
      uiState.currentIndex,
      compact: compact,
    );

    return PickupDashboardCard(
      padding: compact
          ? const EdgeInsets.all(AppSpacing.s12)
          : const EdgeInsets.all(AppSpacing.s16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: compact
            ? _buildCompactContent(uiState, phaseLabel)
            : _buildFullContent(uiState, phaseLabel),
      ),
    );
  }

  Widget _buildCompactContent(
    LaundryTimelineUiState uiState,
    String phaseLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.local_laundry_service_outlined,
                size: 20,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phaseLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (uiState.isSiapDiambilPhase)
              Text(
                'Siap Diambil',
                style: _poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandBlue,
                ),
              ),
          ],
        ),
        if (steps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          LaundryProgressTimeline(
            key: ValueKey('timeline-${order.id}'),
            steps: steps,
            compact: true,
          ),
        ],
      ],
    );
  }

  Widget _buildFullContent(
    LaundryTimelineUiState uiState,
    String phaseLabel,
  ) {
    final phaseDescription = laundryPhaseDescription(uiState.currentIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                order.orderNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (uiState.isSiapDiambilPhase)
              Text(
                'Siap Diambil',
                textAlign: TextAlign.right,
                style: _poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandBlue,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          'Status Laundry',
          style: _poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phaseLabel,
                    style: _poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    phaseDescription,
                    style: _poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (steps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          LaundryProgressTimeline(
            key: ValueKey('timeline-${order.id}'),
            steps: steps,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Ketuk untuk melihat detail status',
            style: _poppins(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
