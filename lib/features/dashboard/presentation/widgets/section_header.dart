import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.onBlueBackground = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool onBlueBackground;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        onBlueBackground ? AppColors.onPrimary : AppColors.textPrimary;
    final actionColor =
        onBlueBackground ? AppColors.accent : AppColors.primary;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: onBlueBackground ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: actionColor,
              ),
            ),
          ),
      ],
    );
  }
}
