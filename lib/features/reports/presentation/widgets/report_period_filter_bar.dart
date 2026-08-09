import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class ReportFilterChip extends StatelessWidget {
  const ReportFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const double minHeight = 44;
  static const double minWidth = 100;
  static const double horizontalPadding = 20;
  static const double verticalPadding = 12;
  static const double borderRadius = 22;
  static const double borderWidth = 1.5;
  static const Duration animationDuration = Duration(milliseconds: 175);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: animationDuration,
          constraints: const BoxConstraints(
            minHeight: minHeight,
            minWidth: minWidth,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.primary,
              width: borderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.onPrimary : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class ReportPeriodFilterBar extends StatelessWidget {
  const ReportPeriodFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final ReportPeriodFilter selectedFilter;
  final ValueChanged<ReportPeriodFilter> onFilterSelected;

  static const _filters = ReportPeriodFilter.values;
  static const _chipSpacing = 12.0;
  static const _horizontalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        12,
        _horizontalPadding,
        8,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            if (i > 0) const SizedBox(width: _chipSpacing),
            ReportFilterChip(
              label: _filters[i].label,
              isSelected: _filters[i] == selectedFilter,
              onTap: () => onFilterSelected(_filters[i]),
            ),
          ],
        ],
      ),
    );
  }
}
