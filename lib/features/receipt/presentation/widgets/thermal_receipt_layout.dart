import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/laundry_receipt_content.dart';

class ThermalReceiptLayout extends StatelessWidget {
  const ThermalReceiptLayout({
    super.key,
    required this.receipt,
    this.paperWidth = ThermalPaperWidth.mm58,
  });

  final LaundryReceipt receipt;
  final ThermalPaperWidth paperWidth;

  @override
  Widget build(BuildContext context) {
    final mode = paperWidth == ThermalPaperWidth.mm58
        ? ReceiptPreviewMode.thermal58
        : ReceiptPreviewMode.thermal80;
    final config = ReceiptLayoutConfig.forMode(mode);

    return Material(
      color: ReceiptTheme.backgroundColor,
      child: LaundryReceiptContent(
        receipt: receipt,
        config: config,
      ),
    );
  }
}

enum ThermalPaperWidth {
  mm58,
  mm80,
}
