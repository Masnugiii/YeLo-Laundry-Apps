import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/incoming_order_status_badge.dart';
import 'package:yelo_laundry_erp/features/orders/utils/order_payment_flow_launcher.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_pic_assignment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_workflow_timeline.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/update_order_status_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/whatsapp_update_dialog.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';

class IncomingOrderCard extends StatefulWidget {
  const IncomingOrderCard({
    super.key,
    required this.order,
  });

  final IncomingOrder order;

  @override
  State<IncomingOrderCard> createState() => _IncomingOrderCardState();
}

class _IncomingOrderCardState extends State<IncomingOrderCard> {
  late IncomingOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  void didUpdateWidget(covariant IncomingOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id) {
      _order = widget.order;
    }
  }

  Future<void> _openUpdateStatus() async {
    final selectedStep = await showUpdateOrderStatusBottomSheet(
      context,
      currentStep: _order.currentStep,
    );

    if (!mounted || selectedStep == null) return;

    if (selectedStep == OrderWorkflowStep.completed) {
      final pendingOrder = _order.copyWith(
        currentStep: selectedStep,
        status: incomingOrderStatusForStep(selectedStep),
      );

      final confirmation = await launchOrderPaymentFlow(
        context,
        order: pendingOrder,
        yeloWalletEnabled: initialAppSettings.yeloWalletEnabled,
      );

      if (!mounted || confirmation == null) return;

      setState(() {
        _order = pendingOrder.copyWith(
          paymentStatus: OrderPaymentStatus.lunas,
        );
      });
      return;
    }

    setState(() {
      _order = _order.copyWith(
        currentStep: selectedStep,
        status: incomingOrderStatusForStep(selectedStep),
      );
    });
  }

  Future<void> _openWhatsappDialog() {
    return showWhatsappUpdateDialog(context, order: _order);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

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
            _InfoRow(label: 'Laundry Service', value: order.service.label),
            _InfoRow(
              label: 'Order Value',
              value: formatRupiah(order.orderValue),
              valueColor: AppColors.primary,
            ),
            _InfoRow(
              label: 'Pickup & Delivery',
              value: order.fulfillmentType.label,
            ),
            const SizedBox(height: AppSpacing.s16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s16),
            _DateBlock(
              title: 'Tanggal Masuk',
              value: formatOrderDateTime(order.receivedAt),
            ),
            const SizedBox(height: AppSpacing.s12),
            _DateBlock(
              title: 'Estimasi Selesai',
              value: formatOrderDateTime(order.estimatedCompletion),
            ),
            if (order.pickupInfo != null) ...[
              const SizedBox(height: AppSpacing.s16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.s16),
              _DateBlock(
                title: 'Pickup Date',
                value: formatOrderDateTime(order.pickupInfo!.dateTime),
              ),
              const SizedBox(height: AppSpacing.s8),
              _InfoRow(label: 'PIC Pickup', value: order.pickupInfo!.pic),
            ],
            if (order.deliveryInfo != null) ...[
              const SizedBox(height: AppSpacing.s12),
              _DateBlock(
                title: 'Delivery Date',
                value: formatOrderDateTime(order.deliveryInfo!.dateTime),
              ),
              const SizedBox(height: AppSpacing.s8),
              _InfoRow(label: 'PIC Delivery', value: order.deliveryInfo!.pic),
            ],
            const SizedBox(height: AppSpacing.s20),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s20),
            OrderWorkflowTimeline(currentStep: order.currentStep),
            const SizedBox(height: AppSpacing.s20),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s20),
            OrderPicAssignment(assignment: order.picAssignment),
            const SizedBox(height: AppSpacing.s20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _openUpdateStatus,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Update Status',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openWhatsappDialog,
                    icon: const Icon(
                      Icons.chat_outlined,
                      size: 18,
                      color: Color(0xFF25D366),
                    ),
                    label: Text(
                      'Kirim Update ke WhatsApp',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
