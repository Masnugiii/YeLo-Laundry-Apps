import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_theme.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/ai_category_badge.dart';

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({
    super.key,
    required this.conversation,
  });

  final WhatsappConversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              conversation.customerName.isNotEmpty
                  ? conversation.customerName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  children: [
                    const Icon(
                      Icons.chat,
                      size: 16,
                      color: Color(0xFF25D366),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Expanded(
                      child: Text(
                        conversation.whatsappNumber,
                        style: CustomerServiceTheme.valueStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderInformationCard extends StatelessWidget {
  const OrderInformationCard({
    super.key,
    required this.order,
  });

  final RelatedOrderInfo order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Order', style: CustomerServiceTheme.sectionTitleStyle),
          const SizedBox(height: AppSpacing.s16),
          _InfoRow(label: 'No. Antrian', value: order.queueNumber),
          const SizedBox(height: AppSpacing.s8),
          _InfoRow(label: 'Layanan Laundry', value: order.laundryService),
          const SizedBox(height: AppSpacing.s8),
          _InfoRow(label: 'Status Saat Ini', value: order.currentStatus),
          const SizedBox(height: AppSpacing.s8),
          _InfoRow(
            label: 'Estimasi Selesai',
            value: formatEstimatedCompletion(order.estimatedCompletion),
          ),
        ],
      ),
    );
  }
}

class ChatTimelineCard extends StatelessWidget {
  const ChatTimelineCard({
    super.key,
    required this.messages,
  });

  final List<WhatsappChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chat Timeline', style: CustomerServiceTheme.sectionTitleStyle),
          const SizedBox(height: AppSpacing.s16),
          for (var i = 0; i < messages.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s12),
            _ChatBubble(message: messages[i]),
          ],
        ],
      ),
    );
  }
}

class AiSummaryCard extends StatelessWidget {
  const AiSummaryCard({
    super.key,
    required this.summary,
    required this.category,
    required this.confidence,
  });

  final String summary;
  final WhatsappMessageCategory category;
  final int confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration.copyWith(
        border: Border.all(
          color: const Color(0xFFF8D613).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'AI Summary',
                style: CustomerServiceTheme.sectionTitleStyle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            summary,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text('Kategori', style: CustomerServiceTheme.labelStyle),
          const SizedBox(height: AppSpacing.s8),
          AiCategoryBadge(category: category),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Text('Confidence', style: CustomerServiceTheme.labelStyle),
              const Spacer(),
              Text(
                '$confidence%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentCategoryCard extends StatelessWidget {
  const CurrentCategoryCard({
    super.key,
    required this.category,
    required this.onChangeCategory,
  });

  final WhatsappMessageCategory category;
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Saat Ini',
            style: CustomerServiceTheme.sectionTitleStyle,
          ),
          const SizedBox(height: AppSpacing.s12),
          AiCategoryBadge(category: category),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onChangeCategory,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Ubah Kategori',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: CustomerServiceTheme.labelStyle),
        ),
        Expanded(
          child: Text(
            value,
            style: CustomerServiceTheme.valueStyle,
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
  });

  final WhatsappChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isFromCustomer;

    return Align(
      alignment: isCustomer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: isCustomer
              ? const Color(0xFFECE5DD)
              : const Color(0xFFDCF8C6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isCustomer ? 4 : 14),
            bottomRight: Radius.circular(isCustomer ? 14 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              formatWhatsappMessageTime(message.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
