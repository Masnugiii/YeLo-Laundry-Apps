import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

String orderServiceLabel(OrderItem order) {
  final summary = order.serviceSummary?.trim();
  if (summary != null && summary.isNotEmpty && summary != '-') {
    return summary;
  }

  final parts = <String>['Laundry'];
  if (order.pickupRequired && order.deliveryRequired) {
    parts.add('Antar Jemput');
  } else if (order.pickupRequired) {
    parts.add('Jemput');
  } else if (order.deliveryRequired) {
    parts.add('Antar');
  }
  return parts.join(' + ');
}

class PendingPaymentCard extends StatelessWidget {
  const PendingPaymentCard({
    super.key,
    required this.order,
    required this.amountText,
    required this.onStatusTap,
  });

  final OrderItem order;
  final String amountText;
  final VoidCallback onStatusTap;

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
            'Pembayaran yang Tertunda',
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
                  Icons.receipt_long_outlined,
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
            'Total Pembayaran',
            style: _poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amountText,
            maxLines: 1,
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
              onTap: onStatusTap,
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

String formatOrderAmount(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
