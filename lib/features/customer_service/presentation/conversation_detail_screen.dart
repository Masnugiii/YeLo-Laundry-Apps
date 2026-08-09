import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/change_category_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/conversation_detail_widgets.dart';
import 'package:yelo_laundry_erp/features/customer_service/providers/customer_service_provider.dart';

class ConversationDetailScreen extends ConsumerWidget {
  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
  });

  final String conversationId;

  Future<void> _changeCategory(
    BuildContext context,
    WidgetRef ref,
    WhatsappConversation conversation,
  ) async {
    final newCategory = await showChangeCategoryBottomSheet(
      context,
      currentCategory: conversation.aiCategory,
    );

    if (!context.mounted || newCategory == null) return;

    await ref.read(customerServiceRepositoryProvider).updateTicketCategory(
          id: conversationId,
          category: newCategory,
        );
    ref.invalidate(customerServiceDetailProvider(conversationId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(customerServiceDetailProvider(conversationId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: conversationState.maybeWhen(
          data: (conversation) => Text(
            conversation?.customerName ?? 'Percakapan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
          orElse: () => Text(
            'Percakapan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
      body: conversationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Gagal memuat percakapan.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        data: (conversation) {
          if (conversation == null) {
            return Center(
              child: Text(
                'Percakapan tidak ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            children: [
              CustomerProfileCard(conversation: conversation),
              const SizedBox(height: AppSpacing.s16),
              if (conversation.relatedOrder != null) ...[
                OrderInformationCard(order: conversation.relatedOrder!),
                const SizedBox(height: AppSpacing.s16),
              ],
              ChatTimelineCard(messages: conversation.messages),
              const SizedBox(height: AppSpacing.s16),
              AiSummaryCard(
                summary: conversation.aiSummary,
                category: conversation.aiCategory,
                confidence: conversation.aiConfidence,
              ),
              const SizedBox(height: AppSpacing.s16),
              CurrentCategoryCard(
                category: conversation.aiCategory,
                onChangeCategory: () =>
                    _changeCategory(context, ref, conversation),
              ),
            ],
          );
        },
      ),
    );
  }
}
