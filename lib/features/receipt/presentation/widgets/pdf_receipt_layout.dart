import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/laundry_receipt_content.dart';

class PdfReceiptLayout extends StatelessWidget {
  const PdfReceiptLayout({
    super.key,
    required this.receipt,
  });

  final LaundryReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final config = ReceiptLayoutConfig.forMode(ReceiptPreviewMode.pdf);

    return Material(
      color: ReceiptTheme.backgroundColor,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: ReceiptTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.md(),
        ),
        clipBehavior: Clip.antiAlias,
        child: LaundryReceiptContent(
          receipt: receipt,
          config: config,
        ),
      ),
    );
  }
}
