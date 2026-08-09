import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_info_row.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_qr_placeholder.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_service_table.dart';

class LaundryReceiptContent extends StatelessWidget {
  const LaundryReceiptContent({
    super.key,
    required this.receipt,
    required this.config,
  });

  final LaundryReceipt receipt;
  final ReceiptLayoutConfig config;

  @override
  Widget build(BuildContext context) {
    final business = receipt.business;
    final base = config.baseFontSize;
    final title = config.titleFontSize;
    final spacing = config.sectionSpacing;

    return Container(
      width: config.width,
      color: ReceiptTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.compact ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              business.logoAsset,
              height: config.logoHeight,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Center(child: Text(business.name, style: ReceiptTheme.titleText(title))),
          SizedBox(height: 4),
          Center(
            child: Text(
              '${business.address}\n${business.city}',
              textAlign: TextAlign.center,
              style: ReceiptTheme.centerText(base),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'WA : ${business.whatsapp}\nInstagram : ${business.instagram}',
              textAlign: TextAlign.center,
              style: ReceiptTheme.centerText(base),
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Order Number',
            value: receipt.orderNumber,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Queue Number',
            value: receipt.queueNumber,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Order Date',
            value: '${receipt.orderDate}\n${receipt.orderTime}',
            fontSize: base,
            multilineValue: true,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Estimated Finish',
            value:
                '${receipt.estimatedFinishDate}\n${receipt.estimatedFinishTime}',
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
            label: 'Phone',
            value: receipt.customerPhone,
            fontSize: base,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptServiceTable(
            lineItems: receipt.lineItems,
            fontSize: base,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Subtotal',
            value: formatRupiah(receipt.subtotal),
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Discount',
            value: formatRupiah(receipt.discount),
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Grand Total',
            value: formatRupiah(receipt.grandTotal),
            fontSize: base,
            emphasized: true,
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Payment Method',
            value: receipt.paymentMethod,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Payment Status',
            value: receipt.paymentStatus,
            fontSize: base,
          ),
          if (!config.compact) ...[
            SizedBox(height: spacing),
            const ReceiptDivider(),
            ReceiptInfoRow(
              label: 'Pickup',
              value: receipt.pickupLabel,
              fontSize: base,
            ),
            const ReceiptDivider(),
            ReceiptInfoRow(
              label: 'Delivery',
              value: receipt.deliveryLabel,
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
          Center(
            child: ReceiptQrPlaceholder(
              description: receipt.qrDescription,
              fontSize: base,
              size: config.compact ? 72 : 88,
            ),
          ),
          SizedBox(height: spacing),
          const ReceiptDivider(),
          Center(
            child: Text(
              'Thank You',
              style: ReceiptTheme.titleText(title),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Terima kasih telah menggunakan\n${business.name}',
              textAlign: TextAlign.center,
              style: ReceiptTheme.centerText(base),
            ),
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Customer Service',
            value: business.whatsapp,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Instagram',
            value: business.instagram,
            fontSize: base,
          ),
          const ReceiptDivider(),
          ReceiptInfoRow(
            label: 'Website',
            value: business.website,
            fontSize: base,
          ),
          if (!config.compact) ...[
            SizedBox(height: spacing),
            const ReceiptDivider(),
            Text(
              receipt.bottomNote,
              textAlign: TextAlign.center,
              style: ReceiptTheme.baseText(base - 1),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared printable receipt body used across thermal, PDF, and WhatsApp layouts.
typedef PrintableReceiptWidget = LaundryReceiptContent;
