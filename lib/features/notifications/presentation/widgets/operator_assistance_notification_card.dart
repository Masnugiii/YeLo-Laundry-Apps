import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_notifications.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/notifications/models/operator_assistance_notification.dart';

class OperatorAssistanceNotificationCard extends ConsumerWidget {
  const OperatorAssistanceNotificationCard({
    super.key,
    required this.notification,
  });

  final OperatorAssistanceNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md(),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🆘 Operator Assistance Needed',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'No Binatu staff has accepted this ironing job.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          _DetailRow(label: 'Order Number', value: notification.orderNumber),
          _DetailRow(label: 'Customer Name', value: notification.customerName),
          _DetailRow(
            label: 'Weight',
            value: '${notification.weightKg.toStringAsFixed(1)} Kg',
          ),
          _DetailRow(
            label: 'Waiting Time',
            value: notification.waitingTimeLabel,
          ),
          if (notification.isResolved && notification.acceptedBy != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Accepted by:\n${notification.acceptedBy}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                  height: 1.4,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(binatuOrderProvider.notifier)
                      .acceptJobAsOperator(notification.orderId);
                  context.push('/binatu/orders/${notification.orderId}');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Accept Assistance',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
