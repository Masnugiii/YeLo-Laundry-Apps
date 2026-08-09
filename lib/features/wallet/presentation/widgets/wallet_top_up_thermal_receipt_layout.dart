import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_receipt_content.dart';

class WalletTopUpThermalReceiptLayout extends StatelessWidget {
  const WalletTopUpThermalReceiptLayout({
    super.key,
    required this.receipt,
    this.paperWidth = WalletTopUpReceiptPaperWidth.mm58,
  });

  final WalletTopUpReceipt receipt;
  final WalletTopUpReceiptPaperWidth paperWidth;

  @override
  Widget build(BuildContext context) {
    final mode = paperWidth == WalletTopUpReceiptPaperWidth.mm58
        ? ReceiptPreviewMode.thermal58
        : ReceiptPreviewMode.thermal80;
    final config = ReceiptLayoutConfig.forMode(mode);

    return Material(
      color: ReceiptTheme.backgroundColor,
      child: WalletTopUpReceiptContent(
        receipt: receipt,
        config: config,
      ),
    );
  }
}
