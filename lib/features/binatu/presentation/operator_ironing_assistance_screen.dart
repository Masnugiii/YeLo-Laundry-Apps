import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/widgets/binatu_ironing_order_card.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/ironing_queue_priority_provider.dart';

/// Operator-facing ironing queue for assistance-only jobs.
class OperatorIroningAssistanceScreen extends ConsumerWidget {
  const OperatorIroningAssistanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ironingQueuePriorityProvider);
    final orders = ref.watch(binatuOrderProvider);
    final prioritySettings = ref.watch(ironingQueuePriorityProvider);

    final assistanceOrders = orders
        .where(
          (order) =>
              order.ironingStatus ==
                  BinatuIroningStatus.waitingForOperatorAssistance ||
              order.ironingStatus == BinatuIroningStatus.waitingForBinatu,
        )
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    final waitingForAssistance = assistanceOrders
        .where(
          (order) =>
              order.ironingStatus ==
              BinatuIroningStatus.waitingForOperatorAssistance,
        )
        .length;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Ironing Queue Assistance',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s20,
          AppSpacing.s32,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              'Binatu memiliki prioritas pertama selama '
              '${prioritySettings.waitingTimeMinutes} menit. '
              'Operator hanya dapat membantu setelah waktu tunggu berakhir.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            '$waitingForAssistance pekerjaan siap dibantu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (assistanceOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
                child: Text(
                  'Belum ada pekerjaan setrika yang menunggu bantuan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < assistanceOrders.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.s12),
              BinatuIroningOrderCard(order: assistanceOrders[i]),
            ],
        ],
      ),
    );
  }
}
