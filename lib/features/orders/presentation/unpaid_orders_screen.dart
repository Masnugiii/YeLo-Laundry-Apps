import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/orders/data/dummy_unpaid_orders.dart';
import 'package:yelo_laundry_erp/features/orders/models/unpaid_order.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/unpaid_order_card.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/unpaid_orders_summary_grid.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class UnpaidOrdersScreen extends StatefulWidget {
  const UnpaidOrdersScreen({super.key});

  @override
  State<UnpaidOrdersScreen> createState() => _UnpaidOrdersScreenState();
}

class _UnpaidOrdersScreenState extends State<UnpaidOrdersScreen> {
  static const _filters = UnpaidOrderFilter.values;

  final _searchController = TextEditingController();
  final _orders = dummyUnpaidOrders();

  UnpaidOrderFilter _selectedFilter = UnpaidOrderFilter.semua;
  UnpaidOrderSort _selectedSort = UnpaidOrderSort.tanggalMasuk;
  final Set<String> _paidOrderIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UnpaidOrder> get _activeOrders =>
      _orders.where((order) => !_paidOrderIds.contains(order.id)).toList();

  List<UnpaidOrder> get _visibleOrders {
    final filtered = filterUnpaidOrders(
      orders: _activeOrders,
      query: _searchController.text,
      filter: _selectedFilter,
    );

    return sortUnpaidOrders(orders: filtered, sort: _selectedSort);
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<UnpaidOrderSort>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Urutkan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                RadioGroup<UnpaidOrderSort>(
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final sort in UnpaidOrderSort.values)
                        RadioListTile<UnpaidOrderSort>(
                          value: sort,
                          title: Text(
                            sort.label,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedSort = selected);
    }
  }

  void _markOrderPaid(String orderId) {
    setState(() => _paidOrderIds.add(orderId));
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = _visibleOrders;
    final summary = computeUnpaidOrdersSummary(_activeOrders);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Belum Dibayar',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Urutkan',
            onPressed: _openSortSheet,
            icon: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: visibleOrders.isEmpty
                ? _EmptyState(hasActiveOrders: _activeOrders.isNotEmpty)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    children: [
                      Text(
                        'Daftar order yang belum melakukan pelunasan pembayaran.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      UnpaidOrdersSummaryGrid(summary: summary),
                      const SizedBox(height: AppSpacing.s20),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Cari nama customer, nomor antrian, atau WhatsApp',
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
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.s8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            return SelectableChip(
                              label: filter.label,
                              isSelected: filter == _selectedFilter,
                              onTap: () => setState(
                                () => _selectedFilter = filter,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Urutkan: ${_selectedSort.label}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      ...visibleOrders.map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.s16,
                          ),
                          child: UnpaidOrderCard(
                            order: order,
                            onPaymentConfirmed: () => _markOrderPaid(order.id),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasActiveOrders});

  final bool hasActiveOrders;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasActiveOrders ? '🔍' : '🎉',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              hasActiveOrders
                  ? 'Tidak ada order yang cocok dengan filter.'
                  : 'Semua pembayaran telah lunas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
