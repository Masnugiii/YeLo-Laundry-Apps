import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/notifications/utils/notification_formatters.dart';
import 'package:yelo_laundry_erp/features/notifications/models/cashier_transaction_notification.dart';

class CashierTransactionNotificationCard extends StatelessWidget {
  const CashierTransactionNotificationCard({
    super.key,
    required this.notification,
  });

  final CashierTransactionNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md(),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeBadge(type: notification.type),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  notification.type.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          _DetailRow(
            label: 'Customer Name',
            value: notification.customerName,
          ),
          if (notification.showsOrderNumber && notification.orderNumber != null)
            _DetailRow(
              label: 'Order Number',
              value: notification.orderNumber!,
            ),
          if (notification.type == CashierNotificationType.walletDeduction &&
              notification.orderNumber != null)
            _DetailRow(
              label: 'Order Number',
              value: notification.orderNumber!,
            ),
          if (notification.showsTransactionNumber &&
              notification.transactionNumber != null)
            _DetailRow(
              label: 'Transaction Number',
              value: notification.transactionNumber!,
            ),
          _DetailRow(
            label: 'Payment Amount',
            value: formatRupiah(notification.amount),
            valueColor: AppColors.primary,
            valueWeight: FontWeight.w700,
          ),
          if (notification.showsPaymentMethod)
            _DetailRow(
              label: 'Payment Method',
              value: notification.paymentMethod!,
            ),
          _DetailRow(
            label: 'Transaction Time',
            value: formatCashierNotificationTime(notification.transactionAt),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            formatCashierNotificationRelativeTime(notification.transactionAt),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final CashierNotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        type.iconLabel,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight = FontWeight.w600,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: valueWeight,
                color: valueColor ?? AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
