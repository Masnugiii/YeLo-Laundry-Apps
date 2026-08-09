import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/utils/debouncer.dart';
import 'package:yelo_laundry_erp/features/customer/providers/customer_list_provider.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_card.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  static const _filterLabels = [
    'Semua',
    'Member',
    'Non Member',
    'Deposit',
    'Tanpa Deposit',
  ];

  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  int _selectedFilterIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  List<dynamic> _applyFilter(List<dynamic> customers) {
    switch (_selectedFilterIndex) {
      case 1:
        return customers.where((customer) => customer.isMember).toList();
      case 2:
        return customers.where((customer) => !customer.isMember).toList();
      case 3:
        return customers.where((customer) => customer.hasDeposit).toList();
      case 4:
        return customers.where((customer) => !customer.hasDeposit).toList();
      default:
        return customers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      floatingActionButton: const CustomerFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Customer',
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
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama pelanggan atau nomor HP',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
              ),
              onChanged: (value) {
                _debouncer.run(() {
                  ref.read(customerListProvider.notifier).search(value);
                });
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              scrollDirection: Axis.horizontal,
              itemCount: _filterLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s8),
              itemBuilder: (context, index) {
                return SelectableChip(
                  label: _filterLabels[index],
                  isSelected: _selectedFilterIndex == index,
                  onTap: () => setState(() => _selectedFilterIndex = index),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Expanded(
            child: customersAsync.when(
              loading: () => const ApiSkeletonList(),
              error: (error, _) => ApiErrorView(
                message: messageFromError(error),
                onRetry: () => ref.read(customerListProvider.notifier).refresh(),
              ),
              data: (state) {
                final customers = _applyFilter(state.customers);

                if (customers.isEmpty) {
                  return const Center(child: Text('Belum ada customer.'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(customerListProvider.notifier).refresh(
                        search: _searchController.text,
                      ),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        ref.read(customerListProvider.notifier).loadMore();
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
                          customers.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s12),
                      itemBuilder: (context, index) {
                        if (index >= customers.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.s16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final customer = customers[index];
                        return CustomerCard(
                          customer: customer,
                          onTap: () => context.push('/customers/${customer.id}'),
                        );
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
