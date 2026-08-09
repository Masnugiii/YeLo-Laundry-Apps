import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/providers/incoming_order_provider.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/laundry_job_queue_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class LaundryJobQueueScreen extends ConsumerWidget {
  const LaundryJobQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(incomingOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        title: Text(
          'Laundry Job Queue',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const ApiSkeletonList(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.read(incomingOrderProvider.notifier).refresh(),
        ),
        data: (orders) {
          final pendingOrders =
              orders.where((order) => order.canAcceptLaundryJob).toList();

          if (pendingOrders.isEmpty) {
            return const Center(child: Text('Tidak ada job laundry menunggu.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(incomingOrderProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              itemCount: pendingOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s16),
              itemBuilder: (context, index) {
                return LaundryJobQueueCard(order: pendingOrders[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
