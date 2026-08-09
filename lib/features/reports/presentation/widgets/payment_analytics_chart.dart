import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class PaymentAnalyticsChart extends StatelessWidget {
  const PaymentAnalyticsChart({
    super.key,
    required this.analytics,
  });

  final List<PaymentAnalytic> analytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _PaymentPiePainter(analytics: analytics),
          ),
        ),
        const SizedBox(width: AppSpacing.s20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in analytics) ...[
                _LegendRow(item: item),
                const SizedBox(height: AppSpacing.s12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});

  final PaymentAnalytic item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            item.method,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${item.percentage.toInt()}%',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _PaymentPiePainter extends CustomPainter {
  _PaymentPiePainter({required this.analytics});

  final List<PaymentAnalytic> analytics;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    var startAngle = -math.pi / 2;

    for (final item in analytics) {
      final sweepAngle = 2 * math.pi * (item.percentage / 100);
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    final holePaint = Paint()..color = AppColors.surface;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PaymentPiePainter oldDelegate) =>
      oldDelegate.analytics != analytics;
}
