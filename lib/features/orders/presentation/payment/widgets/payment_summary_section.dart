import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/payment_flow_theme.dart';

class PaymentSummarySection extends StatelessWidget {
  const PaymentSummarySection({
    super.key,
    required this.order,
    this.paymentMethod,
    this.showPaymentMethod = false,
  });

  final IncomingOrder order;
  final OrderPaymentMethod? paymentMethod;
  final bool showPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: PaymentFlowTheme.cardDecoration,
      child: Column(
        children: [
          _Row(label: 'Customer Name', value: order.customerName),
          const SizedBox(height: AppSpacing.s8),
          _Row(label: 'Queue Number', value: order.queueNumber),
          const SizedBox(height: AppSpacing.s8),
          _Row(label: 'Laundry Service', value: order.service.label),
          const SizedBox(height: AppSpacing.s8),
          _Row(label: 'Laundry Weight', value: '${order.weightKg} kg'),
          if (showPaymentMethod && paymentMethod != null) ...[
            const SizedBox(height: AppSpacing.s8),
            _Row(label: 'Payment Method', value: paymentMethod!.label),
          ],
          const Divider(height: AppSpacing.s24),
          _Row(
            label: 'Total Payment',
            value: formatRupiah(order.orderValue),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class PaymentInfoRow extends StatelessWidget {
  const PaymentInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return _Row(label: label, value: value, emphasized: emphasized);
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: PaymentFlowTheme.labelStyle),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              color: emphasized ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
