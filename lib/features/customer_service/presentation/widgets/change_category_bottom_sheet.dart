import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/widgets/ai_category_badge.dart';

Future<WhatsappMessageCategory?> showChangeCategoryBottomSheet(
  BuildContext context, {
  required WhatsappMessageCategory currentCategory,
}) {
  return showModalBottomSheet<WhatsappMessageCategory>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ChangeCategoryBottomSheet(
      currentCategory: currentCategory,
    ),
  );
}

class _ChangeCategoryBottomSheet extends StatefulWidget {
  const _ChangeCategoryBottomSheet({
    required this.currentCategory,
  });

  final WhatsappMessageCategory currentCategory;

  @override
  State<_ChangeCategoryBottomSheet> createState() =>
      _ChangeCategoryBottomSheetState();
}

class _ChangeCategoryBottomSheetState extends State<_ChangeCategoryBottomSheet> {
  late WhatsappMessageCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s20 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Ubah Kategori',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Pilih kategori percakapan secara manual.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: SingleChildScrollView(
              child: RadioGroup<WhatsappMessageCategory>(
                groupValue: _selectedCategory,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                child: Column(
                  children: [
                    for (final category
                        in WhatsappMessageCategoryX.manualCategories)
                      RadioListTile<WhatsappMessageCategory>(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            AiCategoryBadge(category: category),
                          ],
                        ),
                        value: category,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_selectedCategory),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Simpan Kategori',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
