import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_info_row.dart';
import 'package:yelo_laundry_erp/features/settings/data/dummy_laundry_profile.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';

class WalletDeductionReceiptContent extends StatelessWidget {
  const WalletDeductionReceiptContent({
    super.key,
    required this.receipt,
    required this.config,
  });

  final WalletDeductionReceipt receipt;
  final ReceiptLayoutConfig config;

  @override
  Widget build(BuildContext context) {
    final profile = getLaundryProfile();
    final base = config.baseFontSize;
    final title = config.titleFontSize;
    final spacing = config.sectionSpacing;

    return Container(
      width: config.width,
      color: ReceiptTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              profile.logoAsset,
              height: config.logoHeight,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Center(
            child: Text(
              profile.name,
              style: ReceiptTheme.titleText(title),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              profile.fullAddress,
              textAlign: TextAlign.center,
              style: ReceiptTheme.centerText(base),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'WA : ${profile.whatsapp}',
              textAlign: TextAlign.center,
              style: ReceiptTheme.centerText(base),
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Center(
            child: Text(
              'STRUK PENGURANGAN SALDO YELO WALLET',
              textAlign: TextAlign.center,
              style: ReceiptTheme.titleText(title - 1),
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Transaction Number',
            value: receipt.transactionNumber,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Transaction Date',
            value: '${receipt.transactionDate}\n${receipt.transactionTime}',
            fontSize: base,
            multilineValue: true,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Customer Name',
            value: receipt.customerName,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Phone Number',
            value: receipt.phoneNumber,
            fontSize: base,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Saldo Sebelum',
            value: formatRupiah(receipt.balanceBefore),
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Nominal Dipotong',
            value: formatRupiah(receipt.deductionAmount),
            fontSize: base,
            emphasized: true,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Saldo Sesudah',
            value: formatRupiah(receipt.balanceAfter),
            fontSize: base,
            emphasized: true,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Reason',
            value: receipt.reason,
            fontSize: base,
          ),
          if (receipt.relatedOrder != null &&
              receipt.relatedOrder!.isNotEmpty) ...[
            const ReceiptDivider(),
            ReceiptInfoRow(
              label: 'Related Order',
              value: receipt.relatedOrder!,
              fontSize: base,
            ),
          ],
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Kasir',
            value: receipt.cashierName,
            fontSize: base,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Text(
            receipt.footerNote,
            textAlign: TextAlign.center,
            style: ReceiptTheme.baseText(base),
          ),
        ],
      ),
    );
  }
}

typedef WalletDeductionReceiptWidget = WalletDeductionReceiptContent;
