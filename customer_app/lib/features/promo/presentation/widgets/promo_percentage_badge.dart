import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';

class PromoPercentageBadge extends StatelessWidget {
  const PromoPercentageBadge({
    super.key,
    required this.percentage,
    this.size = 44,
  });

  final int percentage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BurstBadgePainter(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$percentage%',
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onAccent,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstBadgePainter extends CustomPainter {
  static const _teeth = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.84;
    final burstPath = _createBurstPath(
      center: center,
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      teeth: _teeth,
    );

    canvas.drawPath(
      burstPath.shift(const Offset(0, 1.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(
      burstPath,
      Paint()..color = AppColors.accent,
    );
  }

  Path _createBurstPath({
    required Offset center,
    required double outerRadius,
    required double innerRadius,
    required int teeth,
  }) {
    final path = Path();
    final step = math.pi / teeth;

    for (var i = 0; i < teeth * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * step;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        final previousAngle = -math.pi / 2 + (i - 1) * step;
        final previousRadius = (i - 1).isEven ? outerRadius : innerRadius;
        final controlRadius = (previousRadius + radius) / 2;
        final controlAngle = (previousAngle + angle) / 2;
        final controlPoint = Offset(
          center.dx + controlRadius * math.cos(controlAngle),
          center.dy + controlRadius * math.sin(controlAngle),
        );
        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          point.dx,
          point.dy,
        );
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
