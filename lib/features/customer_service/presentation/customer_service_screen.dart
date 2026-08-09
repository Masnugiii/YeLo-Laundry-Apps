import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/customer_service/data/dummy_whatsapp_conversations.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_theme.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/change_category_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/cs_summary_grid.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/whatsapp_message_card.dart';
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
  late List<WhatsappConversation> _conversations;
  WhatsappConversationFilter _selectedFilter = WhatsappConversationFilter.semua;

  @override
  void initState() {
    super.initState();
    _conversations = List<WhatsappConversation>.from(dummyWhatsappConversations);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(userRoleProvider);
      markCustomerServiceBadgeRead(ref, role);
      if (role == UserRole.cashier ||
          role == UserRole.cashierLaundry ||
          role == UserRole.cashierLaundryDriver) {
        _markAllConversationsRead();
      }
    });
  }

  void _markAllConversationsRead() {
    setState(() {
      _conversations = _conversations
          .map((conversation) => conversation.copyWith(isUnread: false))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WhatsappConversation> get _filteredConversations =>
      filterWhatsappConversations(
        conversations: _conversations,
        query: _searchController.text,
        filter: _selectedFilter,
      );

  void _updateConversation(WhatsappConversation updated) {
    setState(() {
      _conversations = _conversations
          .map((conversation) =>
              conversation.id == updated.id ? updated : conversation)
          .toList();
    });
  }

  Future<void> _changeCategory(WhatsappConversation conversation) async {
    final newCategory = await showChangeCategoryBottomSheet(
      context,
      currentCategory: conversation.aiCategory,
    );

    if (!mounted || newCategory == null) return;

    _updateConversation(conversation.copyWith(aiCategory: newCategory));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;

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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                const CsSummaryGrid(summary: customerServiceSummary),
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
                        onTap: () =>
                            setState(() => _selectedFilter = filter),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: CustomerServiceTheme.searchDecoration(
                    'Cari nama customer atau nomor WhatsApp...',
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
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
                      onChangeCategory: () => _changeCategory(filtered[i]),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
