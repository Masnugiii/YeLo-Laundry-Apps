import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/company_receipt_header.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_info_row.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';

class WalletDeductionReceiptContent extends ConsumerWidget {
  const WalletDeductionReceiptContent({
    super.key,
    required this.receipt,
    required this.config,
  });

  final WalletDeductionReceipt receipt;
  final ReceiptLayoutConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptSettings = ref.watch(receiptSettingsProvider).value;
    final base = config.baseFontSize;
    final title = config.titleFontSize;
    final spacing = config.sectionSpacing;
    final footerNote = receiptSettings?.footerText?.trim().isNotEmpty == true
        ? receiptSettings!.footerText!
        : receipt.footerNote;

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
          CompanyReceiptHeader(
            config: receiptSettings,
            logoHeight: config.logoHeight,
            titleFontSize: title,
            baseFontSize: base,
            spacing: spacing,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Center(
            child: Text(
              'STRUK PEMBAYARAN YELO WALLET',
              textAlign: TextAlign.center,
              style: ReceiptTheme.titleText(title),
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
            label: 'Nominal Pembayaran',
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
          Text(
            footerNote,
            textAlign: TextAlign.center,
            style: ReceiptTheme.baseText(base),
          ),
        ],
      ),
    );
  }
}
