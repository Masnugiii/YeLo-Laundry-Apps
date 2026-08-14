import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_payment_card.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/completed_order_card.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_active_order_card.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_progress_timeline.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class PendingOrderCard extends StatelessWidget {
  const PendingOrderCard({
    super.key,
    required this.order,
    required this.statusLabel,
    required this.onDetailTap,
  });

  final OrderItem order;
  final String statusLabel;
  final VoidCallback onDetailTap;

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
    return PickupDashboardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesanan Tertunda',
            style: _poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
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
                      orderServiceLabel(order),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Status Pesanan',
            style: _poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            statusLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onDetailTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s4,
                  vertical: AppSpacing.s4,
                ),
                child: Text(
                  'Lihat Detail →',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: _poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PendingOrderEmptyCard extends StatelessWidget {
  const PendingOrderEmptyCard({super.key});

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
    return PickupDashboardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesanan Tertunda',
            style: _poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_laundry_service_outlined,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'Belum ada pesanan tertunda',
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Status Pesanan',
            style: _poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '-',
            style: _poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

String pendingOrderStatusLabel(
  OrderItem order,
  List<LaundryTrackingStep> steps,
) {
  if (steps.isNotEmpty) {
    final uiState = resolveLaundryTimelineUiState(steps);
    return laundryPhaseStatusLabel(uiState.currentIndex, compact: true);
  }
  return orderStatusDisplayLabel(order.orderStatus);
}
