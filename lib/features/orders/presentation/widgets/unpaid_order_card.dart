import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_radius.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/utils/unpaid_order_formatters.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/unpaid_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_badge.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/order_whatsapp_receipt_dialog.dart';
import 'package:yelo_laundry_erp/features/orders/utils/order_payment_flow_launcher.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';

class UnpaidOrderCard extends StatelessWidget {
  const UnpaidOrderCard({
    super.key,
    required this.order,
    this.onPaymentConfirmed,
  });

  final UnpaidOrder order;
  final VoidCallback? onPaymentConfirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardRadius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: order.accentBarColor),
              Expanded(
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  order.customerName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  order.invoiceNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  order.customerPhone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OrderBadge(
                            label: order.paymentStatus.label,
                            backgroundColor:
                                order.paymentStatus.backgroundColor,
                            textColor: order.paymentStatus.textColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      _InfoRow(
                        label: 'Total Harga',
                        value: formatUnpaidAmount(order.totalAmount),
                        valueColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          OrderBadge(
                            label: order.service.label,
                            backgroundColor: AppColors.primary,
                            textColor: AppColors.onPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoField(
                              label: 'Berat (Kg)',
                              value: '${order.weightKg} Kg',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: _InfoField(
                              label: 'Jumlah PCS',
                              value: '${order.quantityPcs} pcs',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoField(
                              label: 'Pickup',
                              value: order.pickupLabel,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: _InfoField(
                              label: 'Delivery',
                              value: order.deliveryLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Tanggal Laundry Diterima',
                        value: formatUnpaidOrderDateTime(order.receivedAt),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'Estimasi Selesai',
                        value: formatUnpaidOrderDateTime(
                          order.estimatedCompletion,
                        ),
                      ),
                      if (order.deliveryDate != null) ...[
                        const SizedBox(height: AppSpacing.s12),
                        _InfoField(
                          label: 'Tanggal Delivery',
                          value: formatUnpaidOrderDateTime(order.deliveryDate!),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s12),
                      _InfoField(
                        label: 'PIC Binatu',
                        value: order.binatuPic,
                      ),
                      if (order.isOverdue) ...[
                        const SizedBox(height: AppSpacing.s12),
                        _InfoField(
                          label: 'Jumlah Hari Terlambat Diambil',
                          value: '${order.lateDays} Hari',
                          valueColor: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        _InfoField(
                          label: 'Total Denda Keterlambatan',
                          value: formatUnpaidAmount(order.lateFee),
                          valueColor: AppColors.primary,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s20),
                      _ActionButtons(
                        order: order,
                        onPaymentConfirmed: onPaymentConfirmed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.order,
    this.onPaymentConfirmed,
  });

  final UnpaidOrder order;
  final VoidCallback? onPaymentConfirmed;

  void _showOrderDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            children: [
              Text(
                'Detail Order ${order.queueNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                order.customerName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _InfoField(
                label: 'Nomor Invoice',
                value: order.invoiceNumber,
              ),
              const SizedBox(height: AppSpacing.s12),
              _InfoField(
                label: 'Status Pembayaran',
                value: order.paymentStatus.label,
              ),
              const SizedBox(height: AppSpacing.s12),
              _InfoField(
                label: 'Total Harga',
                value: formatUnpaidAmount(order.totalAmount),
              ),
              const SizedBox(height: AppSpacing.s12),
              _InfoField(
                label: 'Jenis Layanan',
                value: order.service.label,
              ),
              const SizedBox(height: AppSpacing.s12),
              _InfoField(
                label: 'PIC Binatu',
                value: order.binatuPic,
              ),
              const SizedBox(height: AppSpacing.s20),
              OutlinedButton.icon(
                onPressed: () => showOrderWhatsappReceiptDialog(
                  context,
                  orderId: order.id,
                  subtitle:
                      'Kirim bukti order dengan status BELUM DIBAYAR ke customer.',
                ),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('Kirim Struk via WhatsApp'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmPayment(BuildContext context) async {
    final incomingOrder = IncomingOrder(
      id: order.id,
      queueNumber: order.queueNumber,
      customerName: order.customerName,
      service: LaundryServiceType.regular,
      orderValue: order.totalAmount,
      fulfillmentType: switch (order.fulfillment) {
        UnpaidFulfillmentType.selfPickup => FulfillmentType.selfPickup,
        UnpaidFulfillmentType.pickup => FulfillmentType.pickup,
        UnpaidFulfillmentType.delivery => FulfillmentType.delivery,
      },
      receivedAt: order.receivedAt,
      estimatedCompletion: order.estimatedCompletion,
      currentStep: OrderWorkflowStep.readyForPickup,
      status: IncomingOrderStatus.siapDiambil,
      picAssignment: PicAssignment(
        pickup: '-',
        washing: '-',
        ironing: order.binatuPic,
        qualityCheck: '-',
        delivery: '-',
      ),
      weightKg: order.weightKg,
      paymentStatus: OrderPaymentStatus.belumLunas,
      serviceDisplayName: order.service.label,
    );

    final confirmation = await launchOrderPaymentFlow(
      context,
      order: incomingOrder,
      yeloWalletEnabled: initialAppSettings.yeloWalletEnabled,
    );

    if (!context.mounted || confirmation == null) return;

    onPaymentConfirmed?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        content: Text(
          'Pembayaran berhasil dikonfirmasi.',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: [
        _ActionButton(
          label: 'Lihat Detail',
          icon: Icons.visibility_outlined,
          onTap: () => _showOrderDetail(context),
        ),
        _ActionButton(
          label: 'Proses Pembayaran',
          icon: Icons.payments_outlined,
          highlighted: true,
          onTap: () => _confirmPayment(context),
        ),
        _ActionButton(
          label: 'Cetak Struk',
          icon: Icons.print_outlined,
          onTap: () => context.push('/laundry-receipt'),
        ),
        _ActionButton(
          label: 'Kirim Struk via WhatsApp',
          icon: Icons.chat_outlined,
          onTap: () => showOrderWhatsappReceiptDialog(
            context,
            orderId: order.id,
            subtitle:
                'Kirim bukti order dengan status BELUM DIBAYAR ke customer.',
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: highlighted ? AppColors.primary : AppColors.textSecondary,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            highlighted ? AppColors.primary : AppColors.textPrimary,
        backgroundColor:
            highlighted ? AppColors.accent.withValues(alpha: 0.2) : null,
        side: BorderSide(
          color: highlighted ? AppColors.accent : AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
