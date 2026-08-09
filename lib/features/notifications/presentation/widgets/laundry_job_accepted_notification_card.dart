import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/notifications/data/dummy_cashier_notifications.dart';
import 'package:yelo_laundry_erp/features/notifications/models/laundry_job_accepted_notification.dart';

class LaundryJobAcceptedNotificationCard extends StatelessWidget {
  const LaundryJobAcceptedNotificationCard({
    super.key,
    required this.notification,
  });

  final LaundryJobAcceptedNotification notification;

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
          Text(
            notification.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          _DetailRow(label: 'Order', value: notification.orderNumber),
          _DetailRow(label: 'Customer', value: notification.customerName),
          _DetailRow(label: 'Service', value: notification.serviceName),
          _DetailRow(label: 'Weight', value: notification.weightLabel),
          _DetailRow(
            label: 'Diambil oleh',
            value: notification.acceptedBy,
            valueColor: AppColors.primary,
          ),
          _DetailRow(
            label: 'Accepted Time',
            value: notification.acceptedTimeLabel,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            formatCashierNotificationRelativeTime(notification.acceptedAt),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
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
                fontWeight: FontWeight.w600,
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
