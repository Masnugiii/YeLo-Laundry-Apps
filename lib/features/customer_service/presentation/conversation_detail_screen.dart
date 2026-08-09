import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer_service/data/dummy_whatsapp_conversations.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/change_category_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/conversation_detail_widgets.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
  });

  final String conversationId;

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  WhatsappConversation? _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = findWhatsappConversationById(widget.conversationId);
  }

  Future<void> _changeCategory() async {
    final conversation = _conversation;
    if (conversation == null) return;

    final newCategory = await showChangeCategoryBottomSheet(
      context,
      currentCategory: conversation.aiCategory,
    );

    if (!mounted || newCategory == null) return;

    setState(() {
      _conversation = conversation.copyWith(
        aiCategory: newCategory,
        isUnread: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          conversation?.customerName ?? 'Percakapan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: conversation == null
          ? Center(
              child: Text(
                'Percakapan tidak ditemukan.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView(
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
                  onChangeCategory: _changeCategory,
                ),
              ],
            ),
    );
  }
}
