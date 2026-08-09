import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_theme.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/change_category_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/cs_summary_grid.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/whatsapp_message_card.dart';
import 'package:yelo_laundry_erp/features/customer_service/providers/customer_service_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_menu_badge_actions.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class CustomerServiceScreen extends ConsumerStatefulWidget {
  const CustomerServiceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  ConsumerState<CustomerServiceScreen> createState() =>
      _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends ConsumerState<CustomerServiceScreen> {
  static const _filters = WhatsappConversationFilterX.values;

  final _searchController = TextEditingController();
  WhatsappConversationFilter _selectedFilter = WhatsappConversationFilter.semua;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(userRoleProvider);
      markCustomerServiceBadgeRead(ref, role);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    ref.read(customerServiceListProvider.notifier).refresh(
          search: _searchController.text,
          filter: _selectedFilter,
        );
  }

  Future<void> _changeCategory(WhatsappConversation conversation) async {
    final newCategory = await showChangeCategoryBottomSheet(
      context,
      currentCategory: conversation.aiCategory,
    );

    if (!mounted || newCategory == null) return;

    await ref.read(customerServiceListProvider.notifier).updateCategory(
          conversation: conversation,
          category: newCategory,
          search: _searchController.text,
          filter: _selectedFilter,
        );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(customerServiceListProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Customer Service Center',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gagal memuat percakapan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextButton(onPressed: _reload, child: const Text('Coba lagi')),
            ],
          ),
        ),
        data: (state) {
          final filtered = state.conversations;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s32,
                    ),
                    children: [
                      CsSummaryGrid(summary: state.summary),
                      const SizedBox(height: AppSpacing.s20),
                      SizedBox(
                        height: SelectableChip.height,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.s8),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            return SelectableChip(
                              label: filter.label,
                              isSelected: _selectedFilter == filter,
                              onTap: () {
                                setState(() => _selectedFilter = filter);
                                _reload();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _reload(),
                        decoration: CustomerServiceTheme.searchDecoration(
                          'Cari nama customer atau nomor WhatsApp...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s32,
                          ),
                          child: Center(
                            child: Text(
                              'Tidak ada percakapan ditemukan.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < filtered.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.s12),
                          WhatsappMessageCard(
                            conversation: filtered[i],
                            onOpenConversation: () => context.push(
                              '/customer-service/${filtered[i].id}',
                            ),
                            onChangeCategory: () =>
                                _changeCategory(filtered[i]),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
