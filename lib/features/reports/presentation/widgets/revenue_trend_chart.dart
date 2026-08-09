import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({
    super.key,
    required this.data,
  });

  final List<RevenueTrendPoint> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: CustomPaint(
            painter: _RevenueTrendPainter(data: data),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.primary, label: 'Omzet Kotor'),
            const SizedBox(width: AppSpacing.s20),
            _LegendDot(color: AppColors.accent, label: 'Omzet Bersih'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RevenueTrendPainter extends CustomPainter {
  _RevenueTrendPainter({required this.data});

  final List<RevenueTrendPoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPad = 36.0;
    const rightPad = 12.0;
    const topPad = 12.0;
    const bottomPad = 28.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    final maxValue = data
        .map((point) => point.grossRevenue > point.netRevenue
            ? point.grossRevenue
            : point.netRevenue)
        .reduce((a, b) => a > b ? a : b);

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = topPad + chartHeight * i / 4;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }

    Path buildPath(List<double> values, Color color) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = leftPad + chartWidth * i / (values.length - 1);
        final y = topPad + chartHeight * (1 - values[i] / maxValue);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
      return path;
    }

    buildPath(data.map((e) => e.grossRevenue).toList(), AppColors.primary);
    buildPath(data.map((e) => e.netRevenue).toList(), AppColors.accent);

    final labelStyle = TextStyle(
      fontSize: 10,
      color: AppColors.textSecondary,
      fontFamily: 'Poppins',
    );

    for (var i = 0; i < data.length; i++) {
      final x = leftPad + chartWidth * i / (data.length - 1);
      final tp = TextPainter(
        text: TextSpan(text: data[i].month, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueTrendPainter oldDelegate) =>
      oldDelegate.data != data;
}
