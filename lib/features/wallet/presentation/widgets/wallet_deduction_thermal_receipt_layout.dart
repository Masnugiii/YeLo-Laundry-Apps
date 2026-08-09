import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_deduction_receipt_content.dart';

class WalletDeductionThermalReceiptLayout extends StatelessWidget {
  const WalletDeductionThermalReceiptLayout({
    super.key,
    required this.receipt,
    this.paperWidth = WalletDeductionReceiptPaperWidth.mm58,
  });

  final WalletDeductionReceipt receipt;
  final WalletDeductionReceiptPaperWidth paperWidth;

  @override
  Widget build(BuildContext context) {
    final mode = paperWidth == WalletDeductionReceiptPaperWidth.mm58
        ? ReceiptPreviewMode.thermal58
        : ReceiptPreviewMode.thermal80;
    final config = ReceiptLayoutConfig.forMode(mode);

    return Material(
      color: ReceiptTheme.backgroundColor,
      child: WalletDeductionReceiptContent(
        receipt: receipt,
        config: config,
      ),
    );
  }
}
