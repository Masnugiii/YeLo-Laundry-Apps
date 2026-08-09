import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedBackgroundColor = AppColors.primary,
    this.unselectedBackgroundColor = AppColors.surface,
    this.selectedTextColor = AppColors.onPrimary,
    this.unselectedTextColor = AppColors.primary,
    this.selectedBorderColor = AppColors.primary,
    this.unselectedBorderColor = AppColors.primary,
    this.expand = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final bool expand;

  static const double height = 36;
  static const double horizontalPadding = 16;
  static const double verticalPadding = 8;
  static const double borderWidth = 1.5;
  static const double borderRadius = 20;
  static const Duration animationDuration = Duration(milliseconds: 175);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: animationDuration,
            width: expand ? double.infinity : null,
            height: height,
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isSelected ? selectedBorderColor : unselectedBorderColor,
                width: borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
