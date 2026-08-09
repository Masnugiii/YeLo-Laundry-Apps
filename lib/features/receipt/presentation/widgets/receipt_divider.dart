import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';

class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(
        height: 1,
        thickness: 1,
        color: ReceiptTheme.dividerColor,
      ),
    );
  }
}
