import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class TopServicesChart extends StatelessWidget {
  const TopServicesChart({
    super.key,
    required this.services,
  });

  final List<TopService> services;

  @override
  Widget build(BuildContext context) {
    final maxOrders = services
        .map((service) => service.orderCount)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (var i = 0; i < services.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s16),
          _ServiceBar(
            service: services[i],
            maxOrders: maxOrders,
            index: i,
          ),
        ],
      ],
    );
  }
}

class _ServiceBar extends StatelessWidget {
  const _ServiceBar({
    required this.service,
    required this.maxOrders,
    required this.index,
  });

  final TopService service;
  final int maxOrders;
  final int index;

  @override
  Widget build(BuildContext context) {
    final progress = service.orderCount / maxOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                service.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${service.orderCount} Order',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.divider,
            color: index.isEven ? AppColors.primary : AppColors.accent,
          ),
        ),
      ],
    );
  }
}
