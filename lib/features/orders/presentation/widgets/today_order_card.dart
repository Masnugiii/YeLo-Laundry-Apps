import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/today_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_badge.dart';

class TodayOrderCard extends StatelessWidget {
  const TodayOrderCard({
    super.key,
    required this.order,
  });

  final TodayOrder order;

  static const _cardRadius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: ClipRRect(
        borderRadius: _cardRadius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                color: order.serviceType.accentBarColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nomor Antrian',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  order.queueNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OrderBadge(
                            label: order.status.label,
                            backgroundColor: order.status.badgeBackground,
                            textColor: order.status.badgeText,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      _InfoRow(
                        label: 'Nama Pelanggan',
                        value: order.customerName,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoRow(
                              label: 'Berat Laundry',
                              value: '${order.weightKg} Kg',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: _InfoRow(
                              label: 'Total Harga',
                              value: order.totalPrice,
                              valueColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          OrderBadge(
                            label: order.serviceType.label,
                            backgroundColor: order.serviceType.badgeBackground,
                            textColor: order.serviceType.badgeText,
                          ),
                          OrderBadge(
                            label: order.paymentMethod.label,
                            backgroundColor: order.paymentMethod.badgeBackground,
                            textColor: order.paymentMethod.badgeText,
                            borderColor: order.paymentMethod.badgeBorder,
                          ),
                          OrderBadge(
                            label: order.pickupDelivery.label,
                            backgroundColor: order.pickupDelivery.badgeBackground,
                            textColor: order.pickupDelivery.badgeText,
                            borderColor: order.pickupDelivery.badgeBorder,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
