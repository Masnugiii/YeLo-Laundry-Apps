import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/widgets/wallet_transaction_format.dart';

class WalletTransactionRow extends StatelessWidget {
  const WalletTransactionRow({
    super.key,
    required this.item,
    required this.currency,
    required this.dateFormat,
    this.onTap,
  });

  final WalletTransaction item;
  final NumberFormat currency;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final income = WalletTransactionFormat.isIncome(item);
    final date = WalletTransactionFormat.parseDate(item.createdAt);

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WalletTransactionFormat.title(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    dateFormat.format(date.toLocal()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(
            WalletTransactionFormat.amountLabel(item, currency),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: income ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}
