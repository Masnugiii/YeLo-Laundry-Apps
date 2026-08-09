import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';

class OrderPicAssignment extends StatelessWidget {
  const OrderPicAssignment({
    super.key,
    required this.assignment,
  });

  final PicAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PIC Assignment',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        _PicRow(label: 'Pickup', value: assignment.pickup),
        const _PicDivider(),
        _PicRow(label: 'Washing', value: assignment.washing),
        const _PicDivider(),
        _PicRow(label: 'Ironing', value: assignment.ironing),
        const _PicDivider(),
        _PicRow(label: 'Quality Check', value: assignment.qualityCheck),
        const _PicDivider(),
        _PicRow(label: 'Delivery', value: assignment.delivery),
      ],
    );
  }
}

class _PicRow extends StatelessWidget {
  const _PicRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PicDivider extends StatelessWidget {
  const _PicDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}
