import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_theme.dart';

class CsSummaryGrid extends StatelessWidget {
  const CsSummaryGrid({
    super.key,
    required this.summary,
  });

  final CustomerServiceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Unread Messages',
                value: '${summary.unreadMessages}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'New Complaints',
                value: '${summary.newComplaints}',
                color: const Color(0xFFC62828),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Order Questions',
                value: '${summary.orderQuestions}',
                color: const Color(0xFFF57F17),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _SummaryCard(
                label: 'Completed',
                value: '${summary.completed}',
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: CustomerServiceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CustomerServiceTheme.labelStyle),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
