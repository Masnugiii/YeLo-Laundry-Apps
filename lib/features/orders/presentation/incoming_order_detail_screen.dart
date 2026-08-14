import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/incoming_order_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/erp_app_bar.dart';

final incomingOrderDetailProvider =
    FutureProvider.autoDispose.family<IncomingOrder, String>((ref, orderId) {
  return ref.read(orderRepositoryProvider).fetchOrder(orderId);
});

class IncomingOrderDetailScreen extends ConsumerWidget {
  const IncomingOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(incomingOrderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: orderAsync.maybeWhen(
        data: (order) => ErpAppBar(
          title: order.queueNumber.isNotEmpty
              ? order.queueNumber
              : 'Detail Order',
        ),
        orElse: () => const ErpAppBar(title: 'Detail Order'),
      ),
      body: orderAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(incomingOrderDetailProvider(orderId)),
        ),
        data: (order) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          children: [
            Text(
              order.customerName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            IncomingOrderCard(order: order),
          ],
        ),
      ),
    );
  }
}
