import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_payment_card.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

String orderStatusDisplayLabel(String status) {
  return switch (status.toUpperCase()) {
    'COMPLETED' => 'Selesai',
    'CANCELLED' => 'Dibatalkan',
    'CREATED' => 'Dibuat',
    'WAITING_PAYMENT' => 'Menunggu Pembayaran',
    _ => status.replaceAll('_', ' '),
  };
}

class CompletedOrderCard extends StatelessWidget {
  const CompletedOrderCard({
    super.key,
    required this.order,
    required this.amountText,
    required this.dateText,
    required this.onTap,
  });

  final OrderItem order;
  final String amountText;
  final String dateText;
  final VoidCallback onTap;

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
    final statusLabel = orderStatusDisplayLabel(order.orderStatus);

    return PickupDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 20,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    order.orderNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: _poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              orderServiceLabel(order),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              dateText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: _poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  amountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Text(
                  'Lihat Detail',
                  style: _poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.brandBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
