import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/laundry_receipt_content.dart';

class WhatsappReceiptLayout extends StatelessWidget {
  const WhatsappReceiptLayout({
    super.key,
    required this.receipt,
  });

  final LaundryReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final config = ReceiptLayoutConfig.forMode(ReceiptPreviewMode.whatsapp);

    return Material(
      color: ReceiptTheme.backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: ReceiptTheme.backgroundColor,
          border: Border.all(color: ReceiptTheme.dividerColor),
        ),
        child: LaundryReceiptContent(
          receipt: receipt,
          config: config,
        ),
      ),
    );
  }
}
