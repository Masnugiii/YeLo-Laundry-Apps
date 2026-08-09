import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_view_mappers.dart';
import 'package:yelo_laundry_erp/features/orders/models/today_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/today_order_card.dart';
import 'package:yelo_laundry_erp/features/orders/providers/order_query_providers.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class TodayOrdersScreen extends ConsumerStatefulWidget {
  const TodayOrdersScreen({super.key});

  @override
  ConsumerState<TodayOrdersScreen> createState() => _TodayOrdersScreenState();
}

class _TodayOrdersScreenState extends ConsumerState<TodayOrdersScreen> {
  static const _filterLabels = [
    'Semua',
    'Regular',
    'Express',
    'Menunggu',
    'Diproses',
    'Selesai',
  ];

  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TodayOrder> _filterOrders(List<TodayOrder> orders) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = orders.where((order) {
      if (query.isEmpty) return true;
      return order.customerName.toLowerCase().contains(query) ||
          order.queueNumber.toLowerCase().contains(query);
    }).toList();

    return switch (_selectedFilterIndex) {
      1 => filtered
          .where((order) => order.serviceType == ServiceType.regular)
          .toList(),
      2 => filtered
          .where((order) => order.serviceType == ServiceType.express)
          .toList(),
      3 => filtered
          .where((order) => order.status == LaundryStatus.menunggu)
          .toList(),
      4 => filtered
          .where(
            (order) =>
                order.status == LaundryStatus.dicuci ||
                order.status == LaundryStatus.dikeringkan ||
                order.status == LaundryStatus.disetrika,
          )
          .toList(),
      5 => filtered
          .where(
            (order) =>
                order.status == LaundryStatus.selesai ||
                order.status == LaundryStatus.readyPickup,
          )
          .toList(),
      _ => filtered,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(todayOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Order Hari Ini',
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
              AppSpacing.s8,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari pelanggan atau nomor antrian',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              itemCount: _filterLabels.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedFilterIndex;

                return SelectableChip(
                  label: _filterLabels[index],
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedFilterIndex = index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(
            child: ordersAsync.when(
              loading: () => const ApiLoadingView(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () => ref.invalidate(todayOrdersProvider),
              ),
              data: (incomingOrders) {
                final orders =
                    incomingOrders.map(toTodayOrder).toList(growable: false);
                final visibleOrders = _filterOrders(orders);

                if (visibleOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada order untuk hari ini.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s8,
                    AppSpacing.s20,
                    AppSpacing.s32,
                  ),
                  itemCount: visibleOrders.length,
                  itemBuilder: (context, index) {
                    return TodayOrderCard(order: visibleOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
