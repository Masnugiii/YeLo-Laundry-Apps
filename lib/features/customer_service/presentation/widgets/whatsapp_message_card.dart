import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_theme.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/ai_category_badge.dart';

class WhatsappMessageCard extends StatelessWidget {
  const WhatsappMessageCard({
    super.key,
    required this.conversation,
    required this.onOpenConversation,
    required this.onChangeCategory,
  });

  final WhatsappConversation conversation;
  final VoidCallback onOpenConversation;
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    final order = conversation.relatedOrder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: CustomerServiceTheme.cardDecoration.copyWith(
        border: conversation.isUnread
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.customerName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (conversation.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      conversation.whatsappNumber,
                      style: CustomerServiceTheme.labelStyle,
                    ),
                  ],
                ),
              ),
              Text(
                formatWhatsappMessageTime(conversation.messageTime),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            conversation.messagePreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              AiCategoryBadge(category: conversation.aiCategory),
              const Spacer(),
              Text(
                'Prediksi AI',
                style: CustomerServiceTheme.labelStyle,
              ),
              const SizedBox(width: AppSpacing.s4),
              Text(
                '${conversation.aiConfidence}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (order != null) ...[
            const SizedBox(height: AppSpacing.s16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.dashboardBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Terkait',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _OrderInfoRow(label: 'No. Antrian', value: order.queueNumber),
                  const SizedBox(height: AppSpacing.s4),
                  _OrderInfoRow(
                    label: 'Layanan',
                    value: order.laundryService,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  _OrderInfoRow(
                    label: 'Status',
                    value: order.currentStatus,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  _OrderInfoRow(
                    label: 'Estimasi Selesai',
                    value: formatEstimatedCompletion(order.estimatedCompletion)
                        .replaceAll('\n', ' '),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onOpenConversation,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Buka Percakapan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onChangeCategory,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ubah Kategori',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({
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
          width: 110,
          child: Text(label, style: CustomerServiceTheme.labelStyle),
        ),
        Expanded(
          child: Text(
            value,
            style: CustomerServiceTheme.valueStyle.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
