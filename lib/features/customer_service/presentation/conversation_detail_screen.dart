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
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
  });

  final String conversationId;

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  final _replyController = TextEditingController();
  bool _sendingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _changeCategory(WhatsappConversation conversation) async {
    final newCategory = await showChangeCategoryBottomSheet(
      context,
      currentCategory: conversation.aiCategory,
    );

    if (!mounted || newCategory == null) return;

    await ref.read(customerServiceRepositoryProvider).updateTicketCategory(
          id: widget.conversationId,
          category: newCategory,
        );
    ref.invalidate(customerServiceDetailProvider(widget.conversationId));
  }

  Future<void> _sendReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty || _sendingReply) return;

    setState(() => _sendingReply = true);
    try {
      await ref.read(customerServiceRepositoryProvider).sendReply(
            id: widget.conversationId,
            message: message,
          );
      _replyController.clear();
      ref.invalidate(customerServiceDetailProvider(widget.conversationId));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageFromError(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sendingReply = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationState =
        ref.watch(customerServiceDetailProvider(widget.conversationId));

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
        loading: () => const ApiLoadingView(message: 'Memuat percakapan...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () =>
              ref.invalidate(customerServiceDetailProvider(widget.conversationId)),
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

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s16,
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
                      onChangeCategory: () => _changeCategory(conversation),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s12,
                  AppSpacing.s20,
                  AppSpacing.s20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ketik balasan...',
                          filled: true,
                          fillColor: AppColors.dashboardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton(
                      onPressed: _sendingReply ? null : _sendReply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s12,
                        ),
                      ),
                      child: _sendingReply
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
