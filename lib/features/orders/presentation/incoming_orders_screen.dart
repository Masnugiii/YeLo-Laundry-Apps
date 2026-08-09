import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/utils/debouncer.dart';
import 'package:yelo_laundry_erp/features/orders/providers/order_list_provider.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/incoming_order_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class IncomingOrdersScreen extends ConsumerStatefulWidget {
  const IncomingOrdersScreen({
    super.key,
    this.showBackButton = true,
    this.title = 'Order',
  });

  final bool showBackButton;
  final String title;

  @override
  ConsumerState<IncomingOrdersScreen> createState() =>
      _IncomingOrdersScreenState();
}

class _IncomingOrdersScreenState extends ConsumerState<IncomingOrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari order, customer, atau nomor antrian',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
              onChanged: (value) {
                _debouncer.run(() {
                  ref.read(orderListProvider.notifier).search(value);
                });
              },
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              loading: () => const ApiSkeletonList(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () => ref.read(orderListProvider.notifier).refresh(),
              ),
              data: (state) {
                if (state.orders.isEmpty) {
                  return const Center(child: Text('Belum ada order.'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(orderListProvider.notifier).refresh(
                        search: _searchController.text,
                      ),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        ref.read(orderListProvider.notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        0,
                        AppSpacing.s20,
                        AppSpacing.s32,
                      ),
                      itemCount:
                          state.orders.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s16),
                      itemBuilder: (context, index) {
                        if (index >= state.orders.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.s16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return IncomingOrderCard(order: state.orders[index]);
                      },
                    ),
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
