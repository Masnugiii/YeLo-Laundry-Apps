import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';

class ReceiptQrPlaceholder extends StatelessWidget {
  const ReceiptQrPlaceholder({
    super.key,
    required this.description,
    required this.fontSize,
    required this.size,
  });

  final String description;
  final double fontSize;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ReceiptTheme.dividerColor, width: 1.5),
          ),
          child: CustomPaint(
            painter: _QrPlaceholderPainter(),
            size: Size(size, size),
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: ReceiptTheme.baseText(fontSize),
          ),
        ],
      ],
    );
  }
}

class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = ReceiptTheme.textColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = ReceiptTheme.textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const module = 6.0;
    final cols = (size.width / module).floor();
    final rows = (size.height / module).floor();

    _drawFinder(canvas, fillPaint, strokePaint, 0, 0, module);
    _drawFinder(canvas, fillPaint, strokePaint, cols - 7, 0, module);
    _drawFinder(canvas, fillPaint, strokePaint, 0, rows - 7, module);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (_isFinderArea(col, row, cols, rows)) continue;
        if ((col * 7 + row * 11) % 5 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(col * module, row * module, module - 0.5, module - 0.5),
            fillPaint,
          );
        }
      }
    }
  }

  void _drawFinder(
    Canvas canvas,
    Paint fillPaint,
    Paint strokePaint,
    int col,
    int row,
    double module,
  ) {
    final outer = Rect.fromLTWH(
      col * module,
      row * module,
      module * 7,
      module * 7,
    );
    canvas.drawRect(outer, strokePaint);
    canvas.drawRect(
      Rect.fromLTWH(
        outer.left + module,
        outer.top + module,
        module * 5,
        module * 5,
      ),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        outer.left + module * 2,
        outer.top + module * 2,
        module * 3,
        module * 3,
      ),
      strokePaint..style = PaintingStyle.fill,
    );
    strokePaint.style = PaintingStyle.stroke;
  }

  bool _isFinderArea(int col, int row, int cols, int rows) {
    final inTopLeft = col < 8 && row < 8;
    final inTopRight = col >= cols - 8 && row < 8;
    final inBottomLeft = col < 8 && row >= rows - 8;
    return inTopLeft || inTopRight || inBottomLeft;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
