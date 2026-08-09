import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/incoming_order_status_badge.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_event_timeline.dart';
import 'package:yelo_laundry_erp/features/orders/providers/incoming_order_provider.dart';

class LaundryJobQueueCard extends ConsumerWidget {
  const LaundryJobQueueCard({
    super.key,
    required this.order,
    this.acceptedByName = 'Pak Budi',
  });

  final IncomingOrder order;
  final String acceptedByName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = this.order;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.queueNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        order.customerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IncomingOrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _InfoRow(label: 'Laundry Service', value: order.serviceLabel),
            _InfoRow(
              label: 'Weight',
              value: '${order.weightKg.toStringAsFixed(1)} Kg',
            ),
            if (order.isLaundryJobAccepted) ...[
              const SizedBox(height: AppSpacing.s8),
              _InfoRow(
                label: 'PIC Laundry',
                value: order.laundryPic ?? '-',
                valueColor: AppColors.primary,
              ),
              if (order.laundryAcceptedAt != null)
                _InfoRow(
                  label: 'Accepted Time',
                  value: _formatAcceptedTime(order.laundryAcceptedAt!),
                ),
            ],
            if (order.timelineEntries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s20),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s20),
              OrderEventTimeline(entries: order.timelineEntries),
            ],
            if (order.canAcceptLaundryJob) ...[
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref.read(incomingOrderProvider.notifier).acceptLaundryJob(
                          orderId: order.id,
                          acceptedBy: acceptedByName,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        content: Text(
                          'Pekerjaan ${order.queueNumber} diterima. '
                          'Notifikasi dikirim ke Kasir dan Owner.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Terima Pekerjaan',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAcceptedTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 14,
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
