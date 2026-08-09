import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_notifications.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_notification.dart';

class BinatuNotificationCard extends StatelessWidget {
  const BinatuNotificationCard({
    super.key,
    required this.notification,
  });

  final BinatuNotification notification;

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
            '${notification.type.icon} ${notification.type.title}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (notification.message != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              notification.message!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s12),
          _DetailRow(label: 'Order', value: notification.orderNumber),
          _DetailRow(label: 'Customer', value: notification.customerName),
          if (notification.service != null)
            _DetailRow(label: 'Service', value: notification.service!),
          if (notification.weightKg != null)
            _DetailRow(
              label: 'Weight',
              value: '${notification.weightKg!.toStringAsFixed(1)} Kg',
            ),
          if (notification.assignedBinatu != null)
            _DetailRow(
              label: 'Assigned Binatu',
              value: notification.assignedBinatu!,
              valueColor: AppColors.primary,
            ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '${formatBinatuNotificationTime(notification.createdAt)} · '
            '${formatBinatuNotificationRelativeTime(notification.createdAt)}',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
