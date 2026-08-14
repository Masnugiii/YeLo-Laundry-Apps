import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/providers/point_history_provider.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/models/point_transaction.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_class_card.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_summary_card.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/point_history_card.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class PointHistoryScreen extends ConsumerStatefulWidget {
  const PointHistoryScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  ConsumerState<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends ConsumerState<PointHistoryScreen> {
  static const _filters = PointHistoryFilter.values;

  final _searchController = TextEditingController();
  PointHistoryFilter _selectedFilter = PointHistoryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PointTransaction> _filteredTransactions(List<PointTransaction> transactions) {
    final query = _searchController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesFilter = _selectedFilter == PointHistoryFilter.all ||
          transaction.source.filterCategory == _selectedFilter;

      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      return transaction.formattedDate.toLowerCase().contains(query) ||
          transaction.referenceNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(pointHistoryCustomerProvider(widget.customerId));
    final historyAsync =
        ref.watch(pointHistoryTransactionsProvider(widget.customerId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      floatingActionButton: const CustomerFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Riwayat Point',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(
              pointHistoryTransactionsProvider(widget.customerId),
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: customerAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat data pelanggan...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(
            pointHistoryCustomerProvider(widget.customerId),
          ),
        ),
        data: (customer) => historyAsync.when(
          loading: () => const ApiLoadingView(message: 'Memuat riwayat point...'),
          error: (error, _) => ApiErrorView(
            message: messageFromError(error),
            onRetry: () => ref.invalidate(
              pointHistoryTransactionsProvider(widget.customerId),
            ),
          ),
          data: (transactions) {
            final filtered = _filteredTransactions(transactions);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s12,
                  ),
                  child: LoyaltySummaryCard(
                    customerName: customer.name,
                    currentPoints: customer.points,
                    loyaltyProgress:
                        loyaltyProgressFromPoints(customer.points),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    0,
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
                      hintText: 'Cari tanggal atau nomor referensi',
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
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                    ),
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.s8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;

                      return SelectableChip(
                        label: filter.label,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedFilter = filter);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      0,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    children: [
                      LoyaltyClassCard(
                        loyaltyClass: loyaltyClassFromPoints(customer.points),
                      ),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s32,
                          ),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat point',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        for (final transaction in filtered)
                          PointHistoryCard(transaction: transaction),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
