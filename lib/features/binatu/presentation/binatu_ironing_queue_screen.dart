import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/widgets/binatu_ironing_order_card.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class BinatuIroningQueueScreen extends ConsumerStatefulWidget {
  const BinatuIroningQueueScreen({
    super.key,
    this.showBackButton = true,
    this.showBackToDashboard = false,
  });

  final bool showBackButton;
  final bool showBackToDashboard;

  @override
  ConsumerState<BinatuIroningQueueScreen> createState() =>
      _BinatuIroningQueueScreenState();
}

class _BinatuIroningQueueScreenState
    extends ConsumerState<BinatuIroningQueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filter = ref.read(binatuQueueFilterProvider);
      markBinatuQueueBadgeRead(ref, filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(binatuOrderProvider);
    final filter = ref.watch(binatuQueueFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading:
            widget.showBackButton && !widget.showBackToDashboard,
        leading: widget.showBackToDashboard
            ? const DashboardAppBarBackButton()
            : null,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          filter.label,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                for (final item in BinatuQueueFilter.values) ...[
                  SelectableChip(
                    label: item.label,
                    isSelected: filter == item,
                    onTap: () {
                      ref
                          .read(binatuQueueFilterProvider.notifier)
                          .setFilter(item);
                      markBinatuQueueBadgeRead(ref, item);
                    },
                  ),
                  const SizedBox(width: AppSpacing.s8),
                ],
              ],
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              loading: () => const ApiLoadingView(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () => ref.invalidate(binatuOrderProvider),
              ),
              data: (orders) {
                final filteredOrders = orders
                    .where((order) => filter.matches(order.ironingStatus))
                    .toList()
                  ..sort((a, b) => a.deadline.compareTo(b.deadline));

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada order pada kategori ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(binatuOrderProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s8,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s16),
                    itemBuilder: (context, index) {
                      return BinatuIroningOrderCard(
                        order: filteredOrders[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
