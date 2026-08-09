import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';

class ReceiptServiceTable extends StatelessWidget {
  const ReceiptServiceTable({
    super.key,
    required this.lineItems,
    required this.fontSize,
  });

  final List<LaundryReceiptLineItem> lineItems;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final headerStyle = ReceiptTheme.baseText(fontSize, weight: FontWeight.w700);
    final cellStyle = ReceiptTheme.baseText(fontSize);

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 4, child: Text('Laundry Service', style: headerStyle)),
            Expanded(flex: 2, child: Text('Weight', style: headerStyle)),
            Expanded(
              flex: 3,
              child: Text(
                'Price',
                textAlign: TextAlign.end,
                style: headerStyle,
              ),
            ),
          ],
        ),
        const ReceiptDivider(),
        for (var i = 0; i < lineItems.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(lineItems[i].serviceName, style: cellStyle),
              ),
              Expanded(
                flex: 2,
                child: Text(lineItems[i].weight, style: cellStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  formatRupiah(lineItems[i].price),
                  textAlign: TextAlign.end,
                  style: cellStyle,
                ),
              ),
            ],
          ),
          if (i < lineItems.length - 1) const ReceiptDivider(),
        ],
      ],
    );
  }
}
