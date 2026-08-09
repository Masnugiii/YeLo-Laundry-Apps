import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class ReceiptCustomizationSectionCard extends StatelessWidget {
  const ReceiptCustomizationSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.description,
  });

  final String title;
  final List<Widget> children;
  final String? description;

  static const _cardRadius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        boxShadow: AppShadows.md(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    description!,
                    style: SettingsTheme.tileDescriptionStyle,
                  ),
                ],
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class ReceiptCustomizationCheckbox extends StatelessWidget {
  const ReceiptCustomizationCheckbox({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
          ),
          title: Text(title, style: SettingsTheme.tileTitleStyle),
          value: value,
          onChanged: (checked) {
            if (checked != null) onChanged(checked);
          },
          activeColor: AppColors.primary,
          checkColor: AppColors.onPrimary,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}
