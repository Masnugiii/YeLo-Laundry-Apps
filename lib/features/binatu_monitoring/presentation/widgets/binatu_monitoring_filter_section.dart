import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/utils/date_display_helper.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class BinatuMonitoringFilterSection extends StatelessWidget {
  const BinatuMonitoringFilterSection({
    super.key,
    required this.selectedFilter,
    required this.selectedDate,
    required this.onFilterSelected,
    required this.onDatePickerTap,
  });

  final BinatuMonitoringDateFilter selectedFilter;
  final DateTime selectedDate;
  final ValueChanged<BinatuMonitoringDateFilter> onFilterSelected;
  final VoidCallback onDatePickerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in BinatuMonitoringDateFilter.values) ...[
                SelectableChip(
                  label: filter.label,
                  isSelected: selectedFilter == filter,
                  onTap: () => onFilterSelected(filter),
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onDatePickerTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      DateDisplayHelper.shortIndonesianDate(selectedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showBinatuMonitoringDatePicker(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2024),
    lastDate: DateTime.now(),
    helpText: 'Pilih Tanggal',
    cancelText: 'Batal',
    confirmText: 'Pilih',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            dayStyle: GoogleFonts.poppins(fontSize: 14),
            yearStyle: GoogleFonts.poppins(fontSize: 14),
            weekdayStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
