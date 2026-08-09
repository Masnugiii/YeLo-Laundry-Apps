import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';

class ReceiptInfoRow extends StatelessWidget {
  const ReceiptInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.fontSize,
    this.emphasized = false,
    this.multilineValue = false,
  });

  final String label;
  final String value;
  final double fontSize;
  final bool emphasized;
  final bool multilineValue;

  @override
  Widget build(BuildContext context) {
    final labelStyle = ReceiptTheme.baseText(fontSize);
    final valueStyle = ReceiptTheme.baseText(
      fontSize,
      weight: emphasized ? FontWeight.w700 : FontWeight.w600,
    );

    if (multilineValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(value, style: valueStyle),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}
